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
            return MyBodyResult(info: info)
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
    
    static func syncDatas(complete: ((NSError?) -> Void)) {
        
        if let uuid = braceletUUID {
            BluetoothManager.shareInstance.fire(uuid, info: [:], complete: { (result: ResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void in
                if error == nil {
                    if let braceletResult = result as? BraceletResult {
                        
                        var datas: [[String: AnyObject]] = []
                        for result in braceletResult.results {
                            
                            datas.append([
                                "userId" : Int(result.userId),
                                "steps" : Int(result.steps),
                                "stepsType" : Int(result.stepsType.rawValue),
                                "startTime" : result.startTime.secondTimeInteval(),
                                "endTime" : result.endTime.secondTimeInteval()
                                ])
                            
                            // 插入数据库
                            DBManager.shareInstance().addGoalData({ (inout setDatas: GoalData) -> GoalData in
                                
                                setDatas.dataId = result.dataId
                                setDatas.userId = NSNumber(integer: result.userId)
                                setDatas.isUpload = false
                                
                                setDatas.startTime = result.startTime
                                setDatas.endTime = result.endTime
                                setDatas.steps = NSNumber(unsignedShort: result.steps)
                                setDatas.stepsType = NSNumber(unsignedShort: result.stepsType.rawValue)
                                
                                return setDatas;
                            })
                        }
                        
                        updateGoalData()
                        
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
    
    static func setGoal(type: UserGoalData.GoalType, number: Int?, days: Int?) {
        UserGoalData.type = type
        UserGoalData.number = number
        UserGoalData.days = days
        UserGoalData.setDate = NSDate()
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
}

extension BraceletData {
    init(info: [String: AnyObject]) {
        
        self.dataId = info["dataId"] as! String
        self.userId = (info["userId"] as! NSNumber).integerValue
        
        self.startTime = info["startTime"] as! NSDate
        self.endTime = info["endTime"] as! NSDate
        self.steps = (info["steps"] as! NSNumber).unsignedShortValue
        self.stepsType = StepsType(rawValue: (info["stepsType"] as! NSNumber).unsignedShortValue)!
    }
}

extension GoalManager {
    
}
