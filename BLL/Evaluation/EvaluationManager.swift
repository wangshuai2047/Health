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
        return DeviceManager.shareInstance().scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: UserManager.shareInstance().currentUser.gender, userId: UserManager.shareInstance().currentUser.userId, age: UserManager.shareInstance().currentUser.age, height: UserManager.shareInstance().currentUser.height)
    }
    
    func addTestDatas() {
        
        
        for var i = 40; i >= 0; i-- {
            let weight = 50 + random() % 10
            let waterPercentage = 55 + random() % 11
            let visceralFatContent = 1 + random() % 10
            
            let result = startScaleInputData(Float(weight), waterContent: Float(waterPercentage), visceralFatContent: Float(visceralFatContent))
            
            // 存数据库
            DBManager.shareInstance().addEvaluationData({ (inout setDatas: EvaluationData) -> EvaluationData in
                
                setDatas.dataId = result.dataId
                setDatas.userId = NSNumber(integer: result.userId)
                setDatas.timeStamp = NSDate(timeIntervalSinceNow: NSTimeInterval(-24 * 60 * 60 * i))
                setDatas.isUpload = true
                
                setDatas.weight = result.weight
                setDatas.waterPercentage = result.waterPercentage
                setDatas.visceralFatPercentage = result.visceralFatPercentage
                setDatas.fatPercentage = result.fatPercentage
                setDatas.fatWeight = result.fatWeight
                setDatas.waterWeight = result.waterWeight
                setDatas.muscleWeight = result.muscleWeight
                setDatas.proteinWeight = result.proteinWeight
                setDatas.boneWeight = result.boneWeight
                setDatas.boneMuscleWeight = result.boneMuscleWeight
                
                return setDatas;
            })
        }
        
    }
    
   // 开始测量秤
    func startScale(complete: (info: ScaleResult?, error: NSError?) -> Void) {
        
        
        DeviceManager.shareInstance().scaleHelper.setScaleData(UserManager.shareInstance().currentUser.userId, gender: UserManager.shareInstance().currentUser.gender, age: UserManager.shareInstance().currentUser.age, height: UserManager.shareInstance().currentUser.height)
        
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
                
                self.updateEvaluationData()
            }
            
            complete(info: result, error: err)
        }
    }
    
    // 访客测量
    func visitorStartScale(user: UserModel, complete: (info: ScaleResult?, error: NSError?) -> Void) {
        DeviceManager.shareInstance().scaleHelper.setScaleData(1, gender: user.gender, age: user.age, height: user.height)
        
        DeviceManager.shareInstance().startScale { (var result, err) -> Void in
            
            if err == nil {
                result!.userId = user.userId
            }
            
            complete(info: result, error: err)
        }
    }
    
    static func mouthDaysDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: AnyObject]] {
        return DBManager.shareInstance().queryEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp, userId: UserData.shareInstance().userId!)
    }
    
    func updateEvaluationData() {
        // 获取所有没上传的数据
        let datas = DBManager.shareInstance().queryNoUploadEvaluationDatas()
        
        var uploadDatas: [[String : AnyObject]] = []
        for info in datas {
            let result = ScaleResult(info: info)
            uploadDatas.append(result.uploadInfo((info["timeStamp"] as! NSDate).secondTimeInteval()))
        }
        
        // 上传
        EvaluationRequest.uploadEvaluationDatas(uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                // 更新数据
                DBManager.shareInstance().updateUploadEvaluationDatas(info!)
            }
        }
    }
    
    func deleteEvaluationData(result: ScaleResult) {
        DBManager.shareInstance().deleteEvaluationData(result.dataId,userId: result.userId)
    }
    
    func share(shareType: ShareType, image: UIImage, complete: (NSError?) -> Void) {
        ShareSDKHelper.shareImage(shareType, image: image, isEvaluation: false) { (error: NSError?) -> Void in
            if error == nil {
                DBManager.shareInstance().addShareData(shareType.rawValue)
            }
            
            complete(error)
        }
    }
}
