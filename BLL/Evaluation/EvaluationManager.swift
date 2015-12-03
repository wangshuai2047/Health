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
    
    func scan(complete: (devices: [DeviceManagerProtocol],isTimeOut: Bool, error: NSError?) -> Void) {
        BluetoothManager.shareInstance.scanDevice([DeviceType.MyBody, DeviceType.MyBodyMini, DeviceType.MyBodyPlus]) { (devices: [DeviceManagerProtocol],isTimeOut: Bool, error: NSError?) -> Void in
            complete(devices: devices,isTimeOut: isTimeOut, error: error)
        }
    }
    
    func startScaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float) -> ScaleResultProtocol {
        
        return MyBodyManager.scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: UserManager.shareInstance().currentUser.gender, userId: UserManager.shareInstance().currentUser.userId, age: UserManager.shareInstance().currentUser.age, height: UserManager.shareInstance().currentUser.height)
    }
    
    func addTestDatas() {
        for var i = 41; i >= 0; i-- {
            let weight = 60 + random() % 10
            let waterPercentage = 55 + random() % 11
            let visceralFatContent = 10 + random() % 10
            
            let result = startScaleInputData(Float(weight), waterContent: Float(waterPercentage), visceralFatContent: Float(visceralFatContent))
            
            DBManager.shareInstance().addEvaluationData(result)
        }
    }
    
    func setCheckStatusBlock(complete: (CBCentralManagerState) -> Void) {
        BluetoothManager.shareInstance.setCheckStatusBlock(complete)
    }
    
    // 开始测量秤
    func startScale(complete: (info: ScaleResultProtocol?, isTimeOut: Bool, error: NSError?) -> Void) {
        
        BluetoothManager.shareInstance.scanDevice([DeviceType.MyBody, DeviceType.MyBodyMini, DeviceType.MyBodyPlus]) { (devices: [DeviceManagerProtocol], isTimeOut: Bool, error: NSError?) -> Void in
            
            if error == nil {
                if devices.count > 0 {
                    let userModel = UserManager.shareInstance().currentUser
                    let device = devices.first!
                    BluetoothManager.shareInstance.fire(device.uuid, info: ["userModel" : userModel], complete: { (result: ResultProtocol?, isTimeOut: Bool, error: NSError?) -> Void in
                        if error == nil {
                            if let braceletResult = result as? ScaleResultProtocol {
                                
                                // 存数据库
                                DBManager.shareInstance().addEvaluationData(braceletResult)
                                
                                self.updateEvaluationData()
                            }
                        }
                        complete(info: result as? ScaleResultProtocol,isTimeOut: isTimeOut, error: error)
                    })
                }
            }
            else {
                complete(info: nil,isTimeOut: isTimeOut, error: error)
            }
        }
    }
    
    // 访客测量
    func visitorStartScale(user: UserModel, complete: (info: ScaleResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void) {
        BluetoothManager.shareInstance.scanDevice([DeviceType.MyBody, DeviceType.MyBodyMini, DeviceType.MyBodyPlus]) { (devices: [DeviceManagerProtocol],isTimeOut: Bool, error: NSError?) -> Void in
            
            if error == nil {
                if devices.count > 0 {
                    let device = devices.first!
                    BluetoothManager.shareInstance.fire(device.uuid, info: ["userModel" : user], complete: { (result: ResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void in
                        if error == nil {
                            if let braceletResult = result as? ScaleResultProtocol {
                                
                                // 存数据库
                                DBManager.shareInstance().addEvaluationData(braceletResult)
                            }
                        }
                        complete(info: result as? ScaleResultProtocol,isTimeOut: isTimeOut, error: error)
                    })
                }
            }
            else {
                complete(info: nil,isTimeOut: isTimeOut, error: error)
            }
        }
    }
    
    static func mouthDaysDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: AnyObject]] {
        return DBManager.shareInstance().queryCountEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp, userId: UserManager.shareInstance().currentUser.userId, count: 5)
    }
    
    static func checkAndSyncEvaluationDatas(complete: (NSError?) -> Void) {
        // 看是否需要获取历史信息
        let lastInfo = DBManager.shareInstance().queryLastEvaluationData(UserData.shareInstance().userId!)
        if lastInfo == nil {
            // 去获取历史数据
            EvaluationRequest.queryEvaluationDatas(UserData.shareInstance().userId!, startDate: NSDate(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: NSDate(), complete: { (datas, error: NSError?) -> Void in
                
                if error == nil {
                    var results: [ScaleResultProtocol] = []
                    
                    for data in datas! {
                        var info = data;
                        let fatPercentage = (data["fatPercentage"] as! NSNumber).floatValue
                        info["fatPercentage"] = NSNumber(float: fatPercentage * 100)
                        results.append(ScaleResultProtocolCreate(info, gender: UserData.shareInstance().gender!, age: UserData.shareInstance().age!, height: UserData.shareInstance().height!))
                    }
                    
                    DBManager.shareInstance().addEvaluationDatas(results, isUpload: true)
                }
                
                
                complete(error)
            })
        }
        else {
            complete(nil)
        }
    }
    
    func updateEvaluationData() {
        // 获取所有没上传的数据
        let datas = DBManager.shareInstance().queryNoUploadEvaluationDatas()
        
        var uploadDatas: [[String : AnyObject]] = []
        for info in datas {
            let gender: Bool
            let age: UInt8
            let height: UInt8
            let userId = (info["userId"] as! NSNumber).integerValue
            if let userInfo = DBManager.shareInstance().queryUser(userId) {
                gender = (userInfo["gender"] as! NSNumber).boolValue
                age = (userInfo["age"] as! NSNumber).unsignedCharValue
                height = (userInfo["height"] as! NSNumber).unsignedCharValue
            }
            else {
                gender = UserManager.mainUser.gender
                age = UserManager.mainUser.age
                height = UserManager.mainUser.height
            }
            
            let result = ScaleResultProtocolCreate(info, gender: gender, age: age, height: height)
            uploadDatas.append(result.uploadInfo((info["timeStamp"] as! NSDate).secondTimeInteval()))
        }
        
        // 上传
        EvaluationRequest.uploadEvaluationDatas(UserManager.mainUser.userId, datas: uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                // 更新数据
                DBManager.shareInstance().updateUploadEvaluationDatas(info!)
                
                // 删除一月前数据
                DBManager.shareInstance().deleteEvaluationDatas(NSDate(timeIntervalSinceNow: -31 * 24 * 60 * 60))
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
