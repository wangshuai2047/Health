//
//  HealthDataManager.swift
//  Health
//
//  Created by Yalin on 15/10/15.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class HealthDataManager: NSObject {
    
    static let sharedInstance = HealthDataManager()
    
    // 步行数据
    func saveWalkData(_ startDate: Date, endDate: Date, steps: Double) {
//        AppleHealthKitManager.sharedInstance.saveWalkData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
//            if error != nil {
//                NSLog("Apple Health Kit saveWalkData error: %@", error!);
//            }
//            else {
//                NSLog("Apple Health Kit saveWalkData success");
//            }
//        }
        
        QQHealthManager.sharedInstance.saveWalkData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveWalkData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveWalkData success");
            }
        }
    }
    
    // 睡眠数据
    func saveSleepData(_ startDate: Date, endDate: Date, sleepTime: Int, deepSleepTime: Int) {
//        AppleHealthKitManager.sharedInstance.saveSleepData(startDate, endDate: endDate) { (error: NSError?) -> Void in
//            if error != nil {
//                NSLog("Apple Health Kit saveSleepData error: %@", error!);
//            }
//            else {
//                NSLog("Apple Health Kit saveSleepData success");
//            }
//        }
        
        QQHealthManager.sharedInstance.saveSleepData(startDate, endDate: endDate, sleepTime: sleepTime, deepSleepTime: deepSleepTime) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveSleepData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveSleepData success");
            }
        }
    }
    
    // 体重
    func saveWeightData(_ weight: Float, fatPercentage: Float, bmi: Float, date: Date) {
        
        // 健康中心
//        AppleHealthKitManager.sharedInstance.saveWeightData(weight, date: date) { (error: NSError?) -> Void in
//            if error != nil {
//                NSLog("Apple Health Kit saveWeightData error: %@", error!);
//            }
//            else {
//                NSLog("Apple Health Kit saveWeightData success");
//            }
//        }
//        
//        AppleHealthKitManager.sharedInstance.saveBMIData(bmi, date: date) { (error: NSError?) -> Void in
//            if error != nil {
//                NSLog("Apple Health Kit saveBMIData error: %@", error!);
//            }
//            else {
//                NSLog("Apple Health Kit saveBMIData success");
//            }
//        }
        
        // qq健康中心
        QQHealthManager.sharedInstance.saveWeightData(weight, fatPercentage: fatPercentage, bmi: bmi, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("QQ Health saveWeightData error: %@", error!);
            }
            else {
                NSLog("QQ Health saveWeightData success");
            }
        }
    }
    
    func saveHealthData(_ startDate: Date, endDate: Date, steps: Double, completion: ((NSError?) -> Void)) {
//        HealthKitManager.sharedInstance.saveWalkData(startDate, endDate: endDate, steps: steps, completion: { (error: NSError?) -> Void in
//        })
    }
    
    
    
    func isHealthDataAvailable() -> Bool {
//        return AppleHealthKitManager.sharedInstance.isHealthDataAvailable()
        
        return false
    }
    
    func requestDataShare(_ completion: (NSError?) -> Void) {
//        AppleHealthKitManager.sharedInstance.requestDataShare(completion)
    }
}
