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
        HealthKitManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("%@", error!);
            }
            else {
                NSLog("saveWalkData success");
            }
        }
    }
    
    // 睡眠数据
    func saveSleepData(startDate: NSDate, endDate: NSDate, steps: Double) {
        HealthKitManager.shareInstance().saveSleepData(startDate, endDate: endDate, steps: steps) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("%@", error!);
            }
            else {
                NSLog("saveSleepData success");
            }
        }
    }
    
    // 体重
    func saveWeightData(weight: Float, date:NSDate) {
        HealthKitManager.shareInstance().saveWeightData(weight, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("%@", error!);
            }
            else {
                NSLog("saveWeightData success");
            }
        }
    }
    
    // BMI
    func saveBMIData(bmi: Float, date:NSDate) {
        HealthKitManager.shareInstance().saveBMIData(bmi, date: date) { (error: NSError?) -> Void in
            if error != nil {
                NSLog("%@", error!);
            }
            else {
                NSLog("saveBMIData success");
            }
        }
    }
    
    func saveHealthData(startDate: NSDate, endDate: NSDate, steps: Double, completion: ((NSError?) -> Void)) {
//        HealthKitManager.shareInstance().saveWalkData(startDate, endDate: endDate, steps: steps, completion: { (error: NSError?) -> Void in
//        })
    }
    
    
    
    func isHealthDataAvailable() -> Bool {
        return HealthKitManager.shareInstance().isHealthDataAvailable()
        
//        return false
    }
    
    func requestDataShare(completion: (NSError?) -> Void) {
        HealthKitManager.shareInstance().requestDataShare(completion)
    }
}
