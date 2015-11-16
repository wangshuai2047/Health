//
//  HealthManager.swift
//  Health
//
//  Created by Yalin on 15/10/17.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class HealthManager: NSObject {
    
    static private var syncBraceletDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("HealthManager.syncBraceletDate") as? NSDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "HealthManager.syncBraceletDate")
        }
    }
    
    static private var syncScaleDate: NSDate? {
        get {
        return NSUserDefaults.standardUserDefaults().objectForKey("HealthManager.syncScaleDate") as? NSDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "HealthManager.syncScaleDate")
        }
    }
    
    static func syncHealthData() {
        
        if UserData.shareInstance().userId == nil {
            return
        }
        
        // 获取运动步数
        
        // 获取未同步的时间
        var startDate = NSDate(timeIntervalSinceNow: -24 * 60 * 60)
        if let lastSyncDate = syncScaleDate {
            startDate = lastSyncDate
        }
        
        let result: ScaleResultProtocol?
        if let evaluationData = DBManager.shareInstance().queryLastEvaluationData(UserData.shareInstance().userId!) {
            result = ScaleResultProtocolCreate(evaluationData, gender: UserData.shareInstance().gender!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!)
            
            let timeStamp = evaluationData["timeStamp"] as! NSDate;
            
            // 体重
            HealthDataManager.shareInstance().saveWeightData(result!.weight, fatPercentage: result!.fatPercentage, bmi: result!.BMI, date: timeStamp)
            
            syncScaleDate = startDate
        }
        
        
        if let lastSyncDate = syncBraceletDate {
            startDate = lastSyncDate
        }
        else {
            startDate = NSDate(timeIntervalSinceNow: -24 * 60 * 60)
            
        }
        
        let list = DBManager.shareInstance().queryGoalData(startDate, endDate: NSDate())
        let (walkStep , _, sleepTime, deepSleepTime, sleepStartDate, sleepEndDate) = HealthDataHelper.parseOneDaySportDatas(list)
        if list.count > 0 {
            let info = list[0]
            startDate = info["startTime"] as! NSDate
            
            let lastInfo = list.last
            let endDate = lastInfo!["endTime"] as! NSDate
            syncBraceletDate = endDate
            
            // 步行数据
            HealthDataManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: Double(walkStep))
            
            // 睡眠数据
            HealthDataManager.shareInstance().saveSleepData(sleepStartDate, endDate: sleepEndDate , sleepTime: sleepTime, deepSleepTime: deepSleepTime)
        }
        
    }
}
