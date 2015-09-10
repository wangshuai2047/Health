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
    }
    
    var isConnectedMyBodyDevice: Bool {
        return DBManager.shareInstance().haveConnectedScale
    }
    
    func scan(complete: (error: NSError?) -> Void) {
        
//        DeviceManager.shareInstance().scanDevices { (error) -> Void in
//            complete(error: error)
//        }
    }
    
    func startScaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float) -> ScaleResult {
        return DeviceManager.shareInstance().scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: UserData.shareInstance().gender!, userId: UserData.shareInstance().userId!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!)
    }
    
   // 开始测量秤
    func startScale(complete: (info: ScaleResult?, error: NSError?) -> Void) {
        
        DeviceManager.shareInstance().scaleHelper.setScaleData(UserData.shareInstance().userId!, gender: UserData.shareInstance().gender!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!)
        
        DeviceManager.shareInstance().startScale { (result, err) -> Void in
            
            if err == nil {
                // 存数据库
                DBManager.shareInstance().addEvaluationData({ (inout setDatas: EvaluationData) -> EvaluationData in
                    
                    setDatas.dataId = result!.dataId
                    setDatas.userId = NSNumber(integer: result!.userId)
                    setDatas.timeStamp = NSDate()
                    setDatas.isUpload = false
                    
                    setDatas.weight = result!.weight
                    setDatas.waterPercentage = result!.waterPercentage
                    setDatas.visceralFatPercentage = result!.visceralFatPercentage
                    setDatas.fatPercentage = result!.fatPercentage
                    setDatas.fatWeight = result!.fatWeight
                    setDatas.waterWeight = result!.waterWeight
                    setDatas.muscleWeight = result!.muscleWeight
                    setDatas.proteinWeight = result!.proteinWeight
                    setDatas.boneWeight = result!.boneWeight
                    setDatas.boneMuscleWeight = result!.boneMuscleWeight
                    
                    return setDatas;
                })
            }
            
            complete(info: result, error: err)
        }
    }
    
    static func mouthDaysDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: NSObject]] {
        return DBManager.shareInstance().queryEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp)
    }
}
