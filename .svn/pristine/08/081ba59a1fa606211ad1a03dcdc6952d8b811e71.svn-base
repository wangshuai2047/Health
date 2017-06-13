//
//  HealthManager.swift
//  Health
//
//  Created by Yalin on 15/10/17.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class HealthManager: NSObject {
    
    static fileprivate var syncBraceletDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "HealthManager.syncBraceletDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HealthManager.syncBraceletDate")
        }
    }
    
    static fileprivate var syncScaleDate: Date? {
        get {
        return UserDefaults.standard.object(forKey: "HealthManager.syncScaleDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HealthManager.syncScaleDate")
        }
    }
    
    static func syncHealthData() {
        
        if UserData.sharedInstance.userId == nil {
            return
        }
        
        // 获取运动步数
        
        // 获取未同步的时间
        var startDate = Date(timeIntervalSinceNow: -24 * 60 * 60)
        if let lastSyncDate = syncScaleDate {
            startDate = lastSyncDate
        }
        
        let result: ScaleResultProtocol?
        if let evaluationData = DBManager.sharedInstance.queryLastEvaluationData(UserData.sharedInstance.userId!) {
            result = ScaleResultProtocolCreate(evaluationData, gender: UserData.sharedInstance.gender!, age: UserData.sharedInstance.age!, height: UserData.sharedInstance.height!)
            
            let timeStamp = evaluationData["timeStamp"] as! Date;
            
            // 体重
            HealthDataManager.sharedInstance.saveWeightData(result!.weight, fatPercentage: result!.fatPercentage, bmi: result!.BMI, date: timeStamp)
            
            syncScaleDate = startDate
        }
        
        
        if let lastSyncDate = syncBraceletDate {
            startDate = lastSyncDate
        }
        else {
            startDate = Date(timeIntervalSinceNow: -24 * 60 * 60)
            
        }
        
        let list = DBManager.sharedInstance.queryGoalData(startDate, endDate: Date())
        let (walkStep , _, sleepTime, deepSleepTime, sleepStartDate, sleepEndDate) = HealthDataHelper.parseOneDaySportDatas(list)
        if list.count > 0 {
            let info = list[0]
            startDate = info["startTime"] as! Date
            
            let lastInfo = list.last
            let endDate = lastInfo!["endTime"] as! Date
            syncBraceletDate = endDate
            
            // 步行数据
            HealthDataManager.sharedInstance.saveWalkData(startDate, endDate: endDate, steps: Double(walkStep))
            
            // 睡眠数据
            HealthDataManager.sharedInstance.saveSleepData(sleepStartDate, endDate: sleepEndDate , sleepTime: sleepTime, deepSleepTime: deepSleepTime)
        }
        
    }
}
