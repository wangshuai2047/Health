//
//  EvaluationManager.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationManager :NSObject {
    
    class func shareInstance() -> EvaluationManager {
        struct Singleton {
            static var predicate: dispatch_once_t = 0
            static var instance: EvaluationManager? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            Singleton.instance = EvaluationManager()
        })
        
        return Singleton.instance!
    }
    
    override init() {
        super.init()
        VScaleManager.sharedInstance().delegate = self
        VScaleManager.sharedInstance().setCalulateDataWithUserID(UserData.shareInstance().userId!, gender: UserData.shareInstance().gender!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!)
    }
    
    var isConnectedMyBodyDevice: Bool {
        return VScaleManager.sharedInstance().curStatus == VCStatus.Connected
//        return DBManager.shareInstance().haveConnectedScale
    }
    
    func scan(complete: (error: NSError?) -> Void) {
        VScaleManager.sharedInstance().scanDevice { (error: NSError?) -> Void in
            complete(error: error)
        }
    }
    
   // 开始测量秤
    func startScale(complete: (info: [String : AnyObject]?, error: NSError?) -> Void) {
        
        /*
        @"userID" : [NSNumber numberWithInt:result.userID],
        @"gender" : [NSNumber numberWithInt:result.gender],
        @"age" : [NSNumber numberWithInt:result.age],
        @"height" : [NSNumber numberWithInt:result.height],
        @"fatContent" : [NSNumber numberWithFloat:result.fatContent],
        @"waterContent" : [NSNumber numberWithFloat:result.waterContent],
        @"boneContent" : [NSNumber numberWithFloat:result.boneContent],
        @"muscleContent" : [NSNumber numberWithFloat:result.muscleContent],
        @"visceralFatContent" : [NSNumber numberWithInt:result.visceralFatContent],
        @"calorie" : [NSNumber numberWithInt:result.calorie],
        @"bmi" : [NSNumber numberWithFloat:result.bmi],
        */
        
        VScaleManager.sharedInstance().scale { (info: VTFatScaleTestResult?, error: NSError?) -> Void in
//            complete(info: info, error: error)
            
            if error == nil {
                var tempInfo: [String : AnyObject] = [:]
                
                let dataId = NSUUID().UUIDString
                tempInfo["dataId"] = dataId
                
                if let userId = info?.userID {
                    tempInfo["userId"] = NSNumber(unsignedChar: userId)
                }
                
                if let gender = info?.gender {
                    tempInfo["gender"] = NSNumber(unsignedChar: gender)
                }
                
                if let age = info?.age {
                    tempInfo["age"] = NSNumber(unsignedChar: age)
                }
                
                if let height = info?.height {
                    tempInfo["height"] = NSNumber(unsignedChar: height)
                }
                
                if let fatContent = info?.fatContent {
                    tempInfo["fatContent"] = NSNumber(float: fatContent)
                }
                
                if let waterContent = info?.waterContent {
                    tempInfo["waterContent"] = NSNumber(float: waterContent)
                }
                
                if let boneContent = info?.boneContent {
                    tempInfo["boneContent"] = NSNumber(float: boneContent)
                }
                
                if let muscleContent = info?.muscleContent {
                    tempInfo["muscleContent"] = NSNumber(float: muscleContent)
                }
                
                if let visceralFatContent = info?.visceralFatContent {
                    tempInfo["visceralFatContent"] = NSNumber(unsignedChar: visceralFatContent)
                }
                
                if let calorie = info?.calorie {
                    tempInfo["calorie"] = NSNumber(int: calorie)
                }
                
                if let bmi = info?.bmi {
                    tempInfo["bmi"] = NSNumber(float: bmi)
                }
                
                complete(info: tempInfo, error: nil)
                
                // 存数据库
                DBManager.shareInstance().addEvaluationData({ (inout setDatas: EvaluationData) -> EvaluationData in
                    
                    setDatas.dataId = dataId
                    setDatas.userId = NSNumber(unsignedChar: info!.userID)
                    setDatas.fatContent = info!.fatContent
                    setDatas.waterContent = info!.waterContent
                    setDatas.boneContent = info!.boneContent
                    setDatas.muscleContent = info!.muscleContent
                    setDatas.visceralFatContent = NSNumber(unsignedChar: info!.visceralFatContent)
                    setDatas.calorie = NSNumber(int: info!.calorie)
                    setDatas.bmi = info!.bmi
                    
                    setDatas.timeStamp = NSDate()
                    setDatas.isUpload = false
                    
                    return setDatas;
                })
                
            }
            else {
                complete(info: nil, error: error)
            }
        }
    }
}

extension EvaluationManager: VScaleManagerDelegate {
    func updateDeviceStatus(status: VCStatus) {
        
    }
    
    func updateUIDataWithFatScale(result: VTFatScaleTestResult!) {
        
    }
    
    func updateUIDataWithWeightScale(result: VTScaleTestResult!) {
        
    }
}