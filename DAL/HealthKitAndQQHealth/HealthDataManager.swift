//
//  HealthDataManager.swift
//  Health
//
//  Created by Yalin on 15/10/15.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class HealthDataManager: NSObject {
    
    class func shareInstance() -> HealthDataManager {
        struct YYSingle {
            static var predicate: dispatch_once_t = 0
            static var instance: HealthDataManager? = nil
        }
        
        dispatch_once(&YYSingle.predicate, { () -> Void in
            YYSingle.instance = HealthDataManager()
        })
        
        return YYSingle.instance!
    }
    
    // 步行数据
    func saveWalkData(startDate: NSDate, endDate: NSDate, steps: Double) {
        AppleHealthKitManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("Apple Health Kit saveWalkData error: %@", error!);
            }
            else {
                NSLog("Apple Health Kit saveWalkData success");
            }
        }
        
        QQHealthManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveWalkData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveWalkData success");
            }
        }
    }
    
    // 睡眠数据
    func saveSleepData(startDate: NSDate, endDate: NSDate, sleepTime: Int, deepSleepTime: Int) {
        AppleHealthKitManager.shareInstance().saveSleepData(startDate, endDate: endDate) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("Apple Health Kit saveSleepData error: %@", error!);
            }
            else {
                NSLog("Apple Health Kit saveSleepData success");
            }
        }
        
        QQHealthManager.shareInstance().saveSleepData(startDate, endDate: endDate, sleepTime: sleepTime, deepSleepTime: deepSleepTime) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveSleepData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveSleepData success");
            }
        }
    }
    
    // 体重
    func saveWeightData(weight: Float, fatPercentage: Float, bmi: Float, date: NSDate) {
        
        // 健康中心
        AppleHealthKitManager.shareInstance().saveWeightData(weight, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("Apple Health Kit saveWeightData error: %@", error!);
            }
            else {
                NSLog("Apple Health Kit saveWeightData success");
            }
        }
        
        AppleHealthKitManager.shareInstance().saveBMIData(bmi, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("Apple Health Kit saveBMIData error: %@", error!);
            }
            else {
                NSLog("Apple Health Kit saveBMIData success");
            }
        }
        
        // qq健康中心
        QQHealthManager.shareInstance().saveWeightData(weight, fatPercentage: fatPercentage, bmi: bmi, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveWeightData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveWeightData success");
            }
        }
    }
    
    func saveHealthData(startDate: NSDate, endDate: NSDate, steps: Double, completion: ((NSError?) -> Void)) {
//        HealthKitManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: steps, completion: { (error: NSError?) -> Void in
//        })
    }
    
    
    
    func isHealthDataAvailable() -> Bool {
        return AppleHealthKitManager.shareInstance().isHealthDataAvailable()
        
//        return false
    }
    
    func requestDataShare(completion: (NSError?) -> Void) {
        AppleHealthKitManager.shareInstance().requestDataShare(completion)
    }
}
