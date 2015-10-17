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
    
    class func shareInstance() -> HealthKitManager {
        struct YYSingle {
            static var predicate: dispatch_once_t = 0
            static var instance: HealthKitManager? = nil
        }
        
        dispatch_once(&YYSingle.predicate, { () -> Void in
            YYSingle.instance = HealthKitManager()
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

    // 步行数据
    func saveWalkData(startDate: NSDate, endDate: NSDate, steps: Double, completion: ((NSError?) -> Void)) {
        
        if #available(iOS 8.0, *) {
            
            
            authorizeHealthKit({ (success, error) -> Void in
                if error == nil {
                    let quantityType =
                    HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
                    let bpm = HKUnit.countUnit()
                    let quantity = HKQuantity(unit: bpm, doubleValue: steps)
                    
                    let quantitySample = HKQuantitySample(type: quantityType!,
                        quantity: quantity,
                        startDate: startDate,
                        endDate: endDate)
                    
                    healthKitStore.saveObject(quantitySample, withCompletion: { (result: Bool, error: NSError?) -> Void in
                        completion(error)
                    })
                }
                else {
                    completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "Health Kit 授权失败"]))
                }
            })
            
        } else {
            // Fallback on earlier versions
            completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
        }
    }
    
    // 睡眠数据
    func saveSleepData(startDate: NSDate, endDate: NSDate, steps: Double, completion: ((NSError?) -> Void)) {
        if #available(iOS 8.0, *) {
            authorizeHealthKit({ (success, error) -> Void in
                if error == nil {
                    
                    let categoryType =
                    HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                    
                    let categorySample = HKCategorySample(type: categoryType,
                        value: HKCategoryValueSleepAnalysis.Asleep.rawValue,
                        startDate: startDate,
                        endDate: endDate,
                        metadata:nil)
                    
                    healthKitStore.saveObject(categorySample, withCompletion: { (result: Bool, error: NSError?) -> Void in
                        completion(error)
                    })
                }
                else {
                    completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "Health Kit 授权失败"]))
                }
            })
            
        } else {
            // Fallback on earlier versions
            completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
        }
    }
    
    // 体重
    func saveWeightData(weight: Float, date: NSDate, completion: ((NSError?) -> Void)) {
        if #available(iOS 8.0, *) {
            
            authorizeHealthKit({ (success, error) -> Void in
                if error == nil {
                    let quantityType =
                    HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
                    let bpm = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo)
                    let quantity = HKQuantity(unit: bpm, doubleValue: Double(weight))
                    
                    let quantitySample = HKQuantitySample(type: quantityType!,
                        quantity: quantity,
                        startDate: date,
                        endDate: date)
                    
                    healthKitStore.saveObject(quantitySample, withCompletion: { (result: Bool, error: NSError?) -> Void in
                        completion(error)
                    })
                }
                else {
                    completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "Health Kit 授权失败"]))
                }
            })
            
            
            
        } else {
            // Fallback on earlier versions
            completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
        }
    }
    
    // BMI
    func saveBMIData(bmi: Float, date: NSDate, completion: ((NSError?) -> Void)) {
        if #available(iOS 8.0, *) {
            
            authorizeHealthKit({ (success, error) -> Void in
                if error == nil {
                    // 1. Create a BMI Sample
                    let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
                    let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: Double(bmi))
                    let bmiSample = HKQuantitySample(type: bmiType!, quantity: bmiQuantity, startDate: date, endDate: date)
                    
                    healthKitStore.saveObject(bmiSample, withCompletion: { (result: Bool, error: NSError?) -> Void in
                        completion(error)
                    })
                }
                else {
                    completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "Health Kit 授权失败"]))
                }
            })
            
            
            
        } else {
            // Fallback on earlier versions
            completion(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey : "设备不支持Health Kit"]))
        }
    }
    
    func checkAuth() {
        
    }
    
    @available(iOS 8.0, *)
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // type of expression is ambiguous without more context
        // 1. Set the types you want to read from HK Store
        
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = Set(arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
            )
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
}
