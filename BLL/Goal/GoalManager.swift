//
//  GoalManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct GoalManager {
    static func isConnectDevice() -> Bool {
        return DBManager.shareInstance().haveConnectedBracelet
    }
    
    static var braceletUUID: String? {
        if let info = DBManager.shareInstance().braceletInfo() {
            return info.uuid
        }
        return nil
    }
    
    static func lastEvaluationData() -> ScaleResultProtocol? {
        if let info = DBManager.shareInstance().queryLastEvaluationData(UserData.shareInstance().userId!) {
            return MyBodyResult(info: info, gender: UserData.shareInstance().gender!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!)
        }
        
        return nil
    }
    
    static func currentGoalInfo() -> GoalShowInfo? {
        if let result = GoalManager.lastEvaluationData() {
            return GoalShowInfo(scaleResult: result, sevenDaysDatas: querySevenDaysData())
        }
        
        return nil
    }
    
    static func share(shareType: ShareType, image: UIImage, complete: (NSError?) -> Void) {
        ShareSDKHelper.shareImage(shareType, image: image, isEvaluation: false) { (error: NSError?) -> Void in
            if error == nil {
                let platformType: ThirdPlatformType
                if shareType == ShareType.QQFriend {
                    platformType = ThirdPlatformType.QQ
                }
                else if shareType == ShareType.WeiBo {
                    platformType = ThirdPlatformType.Weibo
                }
                else {
                    platformType = ThirdPlatformType.WeChat
                }
                
                ScoreRequest.share(UserData.shareInstance().userId!, type: 2, platform: platformType, complete: { (error: NSError?) -> Void in
                    
                    if error == nil {
                        DBManager.shareInstance().addShareData(shareType.rawValue)
                    }
                    
                    complete(error)
                })
                
            }
            else {
                complete(error)
            }
        }
    }
    
    static func checkSyncSettingDatas(complete: (NSError?) -> Void) {
        if !isSetGoal {
            GoalRequest.querySettingGoalDatas(UserData.shareInstance().userId!, complete: { (datas, error: NSError?) -> Void in
                
                // "userId":149,"type":2,"number":100,"days":13,"setDate":1451833727}
                if error == nil {
                    let type: UserGoalData.GoalType = UserGoalData.GoalType(rawValue: (datas!["type"] as! NSNumber).integerValue)!
                    let number = (datas!["number"] as! NSNumber).integerValue
                    let days = (datas!["days"] as! NSNumber).integerValue
                    let setDate = NSDate(timeIntervalSince1970: (datas!["setDate"] as! NSNumber).doubleValue)
                    
                    
                    UserGoalData.type = type
                    UserGoalData.number = number
                    UserGoalData.days = days
                    UserGoalData.setDate = setDate
                    
                }
                
                complete(error)
                
            })
        }
        else {
            complete(nil)
        }
    }
    
    static func syncDatas(complete: ((NSError?) -> Void)) {
        
        if let uuid = braceletUUID {
            BluetoothManager.shareInstance.fire(uuid, info: ["userModel" : UserManager.mainUser], complete: { (result: ResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void in
                if error == nil {
                    if let braceletResult = result as? BraceletResult {
                        
                        DBManager.shareInstance().addGoalDatas(braceletResult)
                        
                        updateGoalData()
                        
                        // 删除七天前数据
                        DBManager.shareInstance().deleteGoalDatas(NSDate(timeIntervalSinceNow: -9 * 24 * 60 * 60))
                        
                        refreshSevenDaysData()
                    }
                }
                
                complete(error)
            })
        }
        else {
            complete(NSError(domain: "同步失败", code: 1001, userInfo: [NSLocalizedDescriptionKey : "未绑定设备"]))
        }
    }
    
    static func checkAndSyncGoalDatas(complete: (NSError?) -> Void) {
        // 看是否需要获取历史信息
        let lastInfo = DBManager.shareInstance().queryLastGoalData()
        if lastInfo == nil {
            // 去获取历史数据
            GoalRequest.queryGoalDatas(UserData.shareInstance().userId!, startDate: NSDate(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: NSDate(), complete: { (datas, error: NSError?) -> Void in
                if error == nil {
                    var results: [BraceletData] = []
                    for data in datas! {
                        
                        var muData = data
                        muData["userId"] = UserData.shareInstance().userId!
                        if let startTime = data["startTime"] as? NSString {
                            muData["startTime"] = NSDate(timeIntervalSince1970: startTime.doubleValue)
                        }
                        
                        if let endTime = data["endTime"] as? NSString {
                            muData["endTime"] = NSDate(timeIntervalSince1970: endTime.doubleValue)
                        }
                        
                        if let dataId = data["dataId"] as? NSString {
                            muData["dataId"] = dataId
                        }
                        
                        if let steps = data["steps"] as? NSString {
                            muData["steps"] = NSNumber(integer: steps.integerValue)
                        }
                        
                        if let stepsType = data["stepsType"] as? NSString {
                            muData["stepsType"] = NSNumber(integer: stepsType.integerValue)
                        }
                        
                        results.append(BraceletData(info: muData))
                    }
                    
                    var result = BraceletResult()
                    result.results = results
                    DBManager.shareInstance().addGoalDatas(result)
                }
                complete(error)
            })
        }
        else {
            complete(nil)
        }
    }
    
    private static func updateGoalData() {
        // 获取所有没上传的数据
        let datas = DBManager.shareInstance().queryNoUploadGoalDatas()
        
        var uploadDatas: [[String : AnyObject]] = []
        for info in datas {
            uploadDatas.append([
                "userId" : (info["userId"] as! NSNumber).integerValue,
                "steps" : (info["steps"] as! NSNumber).integerValue,
                "stepsType" : (info["stepsType"] as! NSNumber).integerValue,
                "startTime" : (info["startTime"] as! NSDate).secondTimeInteval(),
                "endTime" : (info["endTime"] as! NSDate).secondTimeInteval()
                ])
        }
        
        // 上传
        GoalRequest.uploadGoalDatas(uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                DBManager.shareInstance().updateUploadGoalDatas(info!)
            }
        }
    }
    
    static var isSetGoal: Bool {
        if UserGoalData.type == .None {
            return false
        }
        else {
            return true
        }
    }
    
    static func setGoal(type: UserGoalData.GoalType, number: Int, days: Int, complete: (NSError?) -> Void) {
        
        let date = NSDate()
        GoalRequest.uploadSettingGoalDatas(UserData.shareInstance().userId!, type: type.rawValue, number: number, days: days, setDate: date) { (error: NSError?) -> Void in
            
            if error == nil {
                UserGoalData.type = type
                UserGoalData.number = number
                UserGoalData.days = days
                UserGoalData.setDate = date
            }
            
            complete(error)
        }
        
        
    }
    
    private static var sevenDaysData: [(Int,Int,Int,Int)] = []
    
    static func refreshSevenDaysData() {
        var queryDatas: [(Int,Int,Int,Int)] = []
        
        // 获取7天数据从今天开始
        let now = NSDate(timeIntervalSinceNow: 24 * 60 * 60)
        var beginDate = now.zeroTime()
        
        for _ in 0...7 {
            
            let endDate = beginDate.dateByAddingTimeInterval(-24 * 60 * 60)
            let list = DBManager.shareInstance().queryGoalData(endDate, endDate: beginDate)
            beginDate = endDate
            
            let (walkStep , runStep, sleepTime, deepSleepTime, _, _) = HealthDataHelper.parseOneDaySportDatas(list)
            queryDatas += [(walkStep,runStep,sleepTime,deepSleepTime)]
        }
        
        GoalManager.sevenDaysData = queryDatas;
    }
    
    // walkStep,runStep,sleepTime,deepSleepTime
    static func querySevenDaysData() -> [(Int,Int,Int,Int)] {
        
        if GoalManager.sevenDaysData.count == 0 {
            refreshSevenDaysData()
        }
        
        return GoalManager.sevenDaysData
    }
    
    // 获取过去七天平均值
    static func querySevenDaysAverageValues() -> (Int, Int) {
        var averageValues = (0,0)
        
        for (walkStep,_,sleepTime,deepSleepTime) in GoalManager.querySevenDaysData() {
            averageValues.0 += Int(walkStep)
            averageValues.1 += Int(sleepTime)
            averageValues.1 += Int(deepSleepTime)
        }
        
        averageValues.0 /= 7
        averageValues.0 /= 7
        
        return averageValues
    }
    
    static func dealSleepMinutesToHours(minutes: Int) -> Int {
        let remainders = minutes % 60
        
        var result = 0
        
        if remainders > 30 {
            result = (remainders + minutes) / 60
        }
        else {
            result = (remainders + minutes) / 60 - 1
        }
        
        if result < 0 {
            result = 0
        }
        
        return result
    }
}

extension BraceletData {
    init(info: [String: AnyObject]) {
        
        self.dataId = NSUUID().UUIDString
        if let dataId = info["dataId"] as? String {
            self.dataId = dataId
        }
        
        if let dataId = info["dataId"] as? NSNumber {
            self.dataId = "\(dataId)"
        }
        
        self.userId = (info["userId"] as! NSNumber).integerValue
        
        self.startTime = info["startTime"] as! NSDate
        self.endTime = info["endTime"] as! NSDate
        self.steps = (info["steps"] as! NSNumber).unsignedShortValue
        self.stepsType = StepsType(rawValue: (info["stepsType"] as! NSNumber).unsignedShortValue)!
    }
}

extension GoalManager {
    
}
