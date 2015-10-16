//
//  HealthKitManager.swift
//  Health
//
//  Created by Yalin on 15/10/16.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit
import HealthKit

@available(iOS 8.0, *)
var healthKitStore = HKHealthStore()

class HealthKitManager: NSObject {
    
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
    
    func isHealthDataAvailable() -> Bool {
        if #available(iOS 8.0, *) {
            return HKHealthStore.isHealthDataAvailable()
            
        } else {
            // Fallback on earlier versions
            return false
        }
    }
    
    func requestDataShare(completion: (NSError?) -> Void) {
            if #available(iOS 8.0, *) {
                
                let healthKitTypesToShare = NSSet(objects: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
                
                healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToShare as? Set<HKSampleType>, readTypes: nil, completion: { (success: Bool, error: NSError?) -> Void in
                    completion(error)
                })
                
            } else {
                // Fallback on earlier versions
                completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
            }
    }

    func saveWalkData(startDate: NSDate, endDate: NSDate, steps: Double, completion: ((NSError?) -> Void)) {
        
        if #available(iOS 8.0, *) {
            let quantityType =
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            let bpm = HKUnit(fromString: "count/min")
            let quantity = HKQuantity(unit: bpm, doubleValue: steps)
            
            let quantitySample = HKQuantitySample(type: quantityType!,
                quantity: quantity,
                startDate: startDate,
                endDate: endDate)
            
            healthKitStore.saveObject(quantitySample, withCompletion: { (result: Bool, error: NSError?) -> Void in
                completion(error)
            })
            
        } else {
            // Fallback on earlier versions
            completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
        }
    }
}
