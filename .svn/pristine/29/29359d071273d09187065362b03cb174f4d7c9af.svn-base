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
        return DBManager.sharedInstance.haveConnectedBracelet
    }
    
    static var braceletUUID: String? {
        if let info = DBManager.sharedInstance.braceletInfo() {
            return info.uuid
        }
        return nil
    }
    
    static func lastEvaluationData() -> ScaleResultProtocol? {
        if let info = DBManager.sharedInstance.queryLastEvaluationData(UserData.sharedInstance.userId!) {
            return MyBodyResult(info: info, gender: UserData.sharedInstance.gender!, age: UserData.sharedInstance.age!, height: UserData.sharedInstance.height!)
        }
        
        return nil
    }
    
    static func currentGoalInfo() -> GoalShowInfo? {
        if let result = GoalManager.lastEvaluationData() {
            return GoalShowInfo(scaleResult: result, sevenDaysDatas: querySevenDaysData())
        }
        
        return nil
    }
    
    static func share(_ shareType: ShareType, image: UIImage, complete: @escaping (NSError?) -> Void) {
        ShareSDKHelper.shareImage(shareType, image: image, isEvaluation: false) { (error: NSError?) -> Void in
            if error == nil {
                let platformType: ThirdPlatformType
                if shareType == ShareType.qqFriend {
                    platformType = ThirdPlatformType.QQ
                }
                else if shareType == ShareType.weiBo {
                    platformType = ThirdPlatformType.Weibo
                }
                else {
                    platformType = ThirdPlatformType.WeChat
                }
                
                ScoreRequest.share(UserData.sharedInstance.userId!, type: 2, platform: platformType, complete: { (error: NSError?) -> Void in
                    
                    if error == nil {
                        DBManager.sharedInstance.addShareData(shareType.rawValue)
                    }
                    
                    complete(error)
                })
                
            }
            else {
                complete(error)
            }
        }
    }
    
    static func checkSyncSettingDatas(_ complete: @escaping (NSError?) -> Void) {
        if !isSetGoal {
            GoalRequest.querySettingGoalDatas(UserData.sharedInstance.userId!, complete: { (datas, error: NSError?) -> Void in
                
                // "userId":149,"type":2,"number":100,"days":13,"setDate":1451833727}
                if error == nil {
                    let type: UserGoalData.GoalType = UserGoalData.GoalType(rawValue: (datas!["type"] as! NSNumber).intValue)!
                    let number = (datas!["number"] as! NSNumber).intValue
                    let days = (datas!["days"] as! NSNumber).intValue
                    let setDate = Date(timeIntervalSince1970: (datas!["setDate"] as! NSNumber).doubleValue)
                    
                    
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
    
    static func syncDatas(_ complete: @escaping ((NSError?) -> Void)) {
        
        if let uuid = braceletUUID {
            BluetoothManager.shareInstance.fire(uuid, info: ["userModel" : UserManager.mainUser], complete: { (result: ResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void in
                if error == nil {
                    if let braceletResult = result as? BraceletResult {
                        
                        DBManager.sharedInstance.addGoalDatas(braceletResult)
                        
                        updateGoalData()
                        
                        // 删除七天前数据
                        DBManager.sharedInstance.deleteGoalDatas(Date(timeIntervalSinceNow: -9 * 24 * 60 * 60))
                        
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
    
    static func checkAndSyncGoalDatas(_ complete: @escaping (NSError?) -> Void) {
        // 看是否需要获取历史信息
        let lastInfo = DBManager.sharedInstance.queryLastGoalData()
        if lastInfo == nil {
            // 去获取历史数据
            GoalRequest.queryGoalDatas(UserData.sharedInstance.userId!, startDate: Date(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: Date(), complete: { (datas, error: NSError?) -> Void in
                if error == nil {
                    var results: [BraceletData] = []
                    for data in datas! {
                        
                        var muData = data
                        muData["userId"] = UserData.sharedInstance.userId! as AnyObject?
                        if let startTime = data["startTime"] as? NSString {
                            muData["startTime"] = Date(timeIntervalSince1970: startTime.doubleValue) as AnyObject?
                        }
                        
                        if let endTime = data["endTime"] as? NSString {
                            muData["endTime"] = Date(timeIntervalSince1970: endTime.doubleValue) as AnyObject?
                        }
                        
                        if let dataId = data["dataId"] as? NSString {
                            muData["dataId"] = dataId
                        }
                        
                        if let steps = data["steps"] as? NSString {
                            muData["steps"] = NSNumber(value: steps.integerValue as Int)
                        }
                        
                        if let stepsType = data["stepsType"] as? NSString {
                            muData["stepsType"] = NSNumber(value: stepsType.integerValue as Int)
                        }
                        
                        results.append(BraceletData(info: muData))
                    }
                    
                    var result = BraceletResult()
                    result.results = results
                    DBManager.sharedInstance.addGoalDatas(result)
                }
                complete(error)
            })
        }
        else {
            complete(nil)
        }
    }
    
    fileprivate static func updateGoalData() {
        // 获取所有没上传的数据
        let datas = DBManager.sharedInstance.queryNoUploadGoalDatas()
        
        var uploadDatas: [[String : AnyObject]] = []
        for info in datas {
            uploadDatas.append([
                "userId" : (info["userId"] as! NSNumber).intValue as AnyObject,
                "steps" : (info["steps"] as! NSNumber).intValue as AnyObject,
                "stepsType" : (info["stepsType"] as! NSNumber).intValue as AnyObject,
                "startTime" : (info["startTime"] as! Date).secondTimeInteval() as AnyObject,
                "endTime" : (info["endTime"] as! Date).secondTimeInteval() as AnyObject
                ])
        }
        
        // 上传
        GoalRequest.uploadGoalDatas(uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                DBManager.sharedInstance.updateUploadGoalDatas(info!)
            }
        }
    }
    
    static var isSetGoal: Bool {
        if UserGoalData.type == .none {
            return false
        }
        else {
            return true
        }
    }
    
    static func setGoal(_ type: UserGoalData.GoalType, number: Int, days: Int, complete: @escaping (NSError?) -> Void) {
        
        let date = Date()
        GoalRequest.uploadSettingGoalDatas(UserData.sharedInstance.userId!, type: type.rawValue, number: number, days: days, setDate: date) { (error: NSError?) -> Void in
            
            if error == nil {
                UserGoalData.type = type
                UserGoalData.number = number
                UserGoalData.days = days
                UserGoalData.setDate = date
            }
            
            complete(error)
        }
        
        
    }
    
    fileprivate static var sevenDaysData: [(Int,Int,Int,Int)] = []
    
    static func refreshSevenDaysData() {
        var queryDatas: [(Int,Int,Int,Int)] = []
        
        // 获取7天数据从今天开始
        let now = Date(timeIntervalSinceNow: 24 * 60 * 60)
        var beginDate = now.zeroTime()
        
        for _ in 0...7 {
            
            let endDate = beginDate.addingTimeInterval(-24 * 60 * 60)
            let list = DBManager.sharedInstance.queryGoalData(endDate, endDate: beginDate)
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
    
    static func dealSleepMinutesToHours(_ minutes: Int) -> Int {
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
        
        self.dataId = UUID().uuidString
        if let dataId = info["dataId"] as? String {
            self.dataId = dataId
        }
        
        if let dataId = info["dataId"] as? NSNumber {
            self.dataId = "\(dataId)"
        }
        
        self.userId = (info["userId"] as! NSNumber).intValue
        
        self.startTime = info["startTime"] as! Date
        self.endTime = info["endTime"] as! Date
        self.steps = (info["steps"] as! NSNumber).uint16Value
        self.stepsType = StepsType(rawValue: (info["stepsType"] as! NSNumber).uint16Value)!
    }
}

extension GoalManager {
    
}
