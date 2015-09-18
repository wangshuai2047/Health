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
    
    static func lastEvaluationData() -> ScaleResult? {
        if let info = DBManager.shareInstance().queryLastEvaluationData(UserData.shareInstance().userId!) {
            return ScaleResult(info: info)
        }
        
        return nil
    }
    
    static func currentGoalInfo() {
        var goalDescription = UserGoalData.type.description()
    }
    
    static func syncDatas(complete: ((NSError?) -> Void)) {
        
        var startTime: NSDate
        var lastGoalData = DBManager.shareInstance().queryLastGoalData()
        if lastGoalData == nil {
            startTime = NSDate().dateByAddingTimeInterval(-30 * 24 * 60 * 60)
        }
        else {
            startTime = lastGoalData!["endTime"] as! NSDate
        }
        
        startTime = NSDate()
        
        DeviceManager.shareInstance().syncBraceletDatas(startTime, syncComplete: { (list: [BraceletResult], error: NSError?) -> Void in
            
            if error == nil {
                for result in list {
                    // 插入数据库
                    DBManager.shareInstance().addGoalData({ (inout setDatas: GoalData) -> GoalData in
                        
                        setDatas.dataId = result.dataId
                        setDatas.userId = NSNumber(unsignedShort: result.userId)
                        setDatas.isUpload = false
                        
                        setDatas.startTime = result.startTime
                        setDatas.endTime = result.endTime
                        setDatas.steps = NSNumber(unsignedShort: result.steps)
                        setDatas.stepsType = NSNumber(unsignedShort: result.stepsType)
                        
                        return setDatas;
                    })
                }
            }
            
            complete(error)
        })
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
    
    
    static func querySevenDaysData() -> [(UInt16,UInt16,UInt16)] {
        
        var queryDatas: [(UInt16,UInt16,UInt16)] = []
        
        // 获取7天数据从今天开始
        let now = NSDate(timeIntervalSinceNow: 24 * 60 * 60)
        var beginDate = now.zeroTime()
        
        for _ in 0...6 {
            
            let endDate = beginDate.dateByAddingTimeInterval(-24 * 60 * 60)
            let list = DBManager.shareInstance().queryGoalData(endDate, endDate: beginDate)
            beginDate = endDate
            
            var walkStep: UInt16 = 0
            var runStep: UInt16 = 0
            var sleepTime: UInt16 = 0
            
            for data in list {
                let result = BraceletResult(info: data)
                
                if result.stepsType == 10 // 走路 
                {
                    walkStep += result.steps
                }
                else if result.stepsType == 11 // 跑步
                {
                    runStep += result.steps
                }
                else if result.stepsType == 9 // 睡觉
                {
                    sleepTime += result.steps
                }
            }
            
            queryDatas += [(walkStep,runStep,sleepTime)]
        }
        
        return queryDatas
    }
    
}

extension BraceletResult {
    init(info: [String: NSObject]) {
        
        self.dataId = info["dataId"] as! String
        self.userId = (info["userId"] as! NSNumber).unsignedShortValue
        
        self.startTime = info["startTime"] as! NSDate
        self.endTime = info["endTime"] as! NSDate
        self.steps = (info["steps"] as! NSNumber).unsignedShortValue
        self.stepsType = (info["stepsType"] as! NSNumber).unsignedShortValue
    }
}
