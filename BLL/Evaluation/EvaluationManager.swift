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
        return DBManager.shareInstance().haveConnectedScale
    }
    
    func scan(complete: (error: NSError?) -> Void) {
        VScaleManager.sharedInstance().scanDevice { (error: NSError?) -> Void in
            complete(error: error)
        }
    }
    
   // 开始测量秤
    func startScale(complete: (info: [NSObject : AnyObject]?, error: NSError?) -> Void) {
        
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
            
            // 存数据库
            DBManager.shareInstance().addEvaluationData({ (inout setDatas: EvaluationData) -> EvaluationData in
                
                
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