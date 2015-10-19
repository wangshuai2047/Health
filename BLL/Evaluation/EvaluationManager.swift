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
    
    var myBodyUUID: String? {
        if let info = DBManager.shareInstance().myBodyInfo() {
            return info.uuid
        }
        return nil
    }
    
    override init() {
        super.init()
    }
    
    var isConnectedMyBodyDevice: Bool {
        return DBManager.shareInstance().haveConnectedScale
    }
    
    func scan(complete: (devices: [DeviceManagerProtocol], error: NSError?) -> Void) {
        BluetoothManager.shareInstance.scanDevice([DeviceType.MyBody, DeviceType.MyBodyMini, DeviceType.MyBodyPlus]) { (devices: [DeviceManagerProtocol]) -> Void in
            complete(devices: devices, error: nil)
        }
    }
    
    func startScaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float) -> ScaleResultProtocol {
        
        return MyBodyManager.scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: UserManager.shareInstance().currentUser.gender, userId: UserManager.shareInstance().currentUser.userId, age: UserManager.shareInstance().currentUser.age, height: UserManager.shareInstance().currentUser.height)
    }
    
    func addTestDatas() {
        for var i = 40; i >= 0; i-- {
            let weight = 50 + random() % 10
            let waterPercentage = 55 + random() % 11
            let visceralFatContent = 1 + random() % 10
            
            let result = startScaleInputData(Float(weight), waterContent: Float(waterPercentage), visceralFatContent: Float(visceralFatContent))
            
            DBManager.shareInstance().addEvaluationData(result)
        }
    }
    
   // 开始测量秤
    func startScale(complete: (info: ScaleResultProtocol?, error: NSError?) -> Void) {
        
        if let uuid = myBodyUUID {
            
            // setScaleData(userId: Int, gender: Bool, age: UInt8, height: UInt8)
            let userModel = UserManager.shareInstance().currentUser
            
            BluetoothManager.shareInstance.fire(uuid, info: ["userModel" : userModel], complete: { [unowned self] (result: ResultProtocol?, error: NSError?) -> Void in
                if error == nil {
                    if let braceletResult = result as? ScaleResultProtocol {
                        
                        // 存数据库
                        DBManager.shareInstance().addEvaluationData(braceletResult)
                        
                        self.updateEvaluationData()
                    }
                }
                complete(info: result as? ScaleResultProtocol, error: error)
            })
        }
        else {
            complete(info: nil, error: NSError(domain: "同步失败", code: 1001, userInfo: [NSLocalizedDescriptionKey : "未绑定设备"]))
        }
    }
    
    // 访客测量
    func visitorStartScale(user: UserModel, complete: (info: ScaleResultProtocol?, error: NSError?) -> Void) {
        if let uuid = myBodyUUID {
            BluetoothManager.shareInstance.fire(uuid, info: ["userModel" : user as! AnyObject], complete: { (result: ResultProtocol?, error: NSError?) -> Void in
                
                    complete(info: result as? ScaleResultProtocol, error: error)
                })
        }
        else {
            complete(info: nil, error: NSError(domain: "同步失败", code: 1001, userInfo: [NSLocalizedDescriptionKey : "未绑定设备"]))
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
            let result = MyBodyResult(info: info)
            uploadDatas.append(result.uploadInfo((info["timeStamp"] as! NSDate).secondTimeInteval()))
        }
        
        // 上传
        EvaluationRequest.uploadEvaluationDatas(UserManager.mainUser.userId, datas: uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                // 更新数据
                DBManager.shareInstance().updateUploadEvaluationDatas(info!)
            }
        }
    }
    
    func deleteEvaluationData(result: ScaleResultProtocol) {
        DBManager.shareInstance().deleteEvaluationData(result.dataId,userId: result.userId)
    }
    
    func share(shareType: ShareType, image: UIImage, complete: (NSError?) -> Void) {
        ShareSDKHelper.shareImage(shareType, image: image, isEvaluation: false) { (error: NSError?) -> Void in
            
            if error == nil {
                let platformType: ThirdPlatformType
                if shareType == ShareType.QQFriend {
                    platformType = ThirdPlatformType.QQ
                }
                else if shareType == ShareType.WeiBo {
                    platformType = ThirdPlatformType.Weibo
                }
                else {
                    platformType = ThirdPlatformType.WeChat
                }
                
                ScoreRequest.share(UserData.shareInstance().userId!, type: 1, platform: platformType, complete: { (error: NSError?) -> Void in
                    
                    if error == nil {
                        DBManager.shareInstance().addShareData(shareType.rawValue)
                    }
                    
                    complete(error)
                })
                
            }
            else {
                complete(error)
            }
            
        }
    }
}
