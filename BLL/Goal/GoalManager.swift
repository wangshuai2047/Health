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
    
    static func syncDatas(complete: ((NSError?) -> Void)) {
        
        var startTime: NSDate
        var lastGoalData = DBManager.shareInstance().queryLastGoalData()
        if lastGoalData == nil {
            startTime = NSDate().dateByAddingTimeInterval(-30 * 24 * 60 * 60)
        }
        else {
            startTime = lastGoalData!.endTime
        }
        
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
    }
    
    
    static func querySevenDaysData() {
        
    }
    
}
