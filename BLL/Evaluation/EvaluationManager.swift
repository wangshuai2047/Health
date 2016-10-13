//
//  EvaluationManager.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class EvaluationManager :NSObject {
    
    static let sharedInstance = EvaluationManager()
    
    var myBodyUUID: String? {
        if let info = DBManager.sharedInstance.myBodyInfo() {
            return info.uuid
        }
        return nil
    }
    
    override init() {
        super.init()
    }
    
    var isConnectedMyBodyDevice: Bool {
        return DBManager.sharedInstance.haveConnectedScale
    }
    
    func scan(_ complete: @escaping (_ devices: [DeviceManagerProtocol],_ isTimeOut: Bool, _ error: NSError?) -> Void) {
        BluetoothManager.shareInstance.scanDevice([DeviceType.myBody, DeviceType.myBodyMini, DeviceType.myBodyPlus]) { (devices: [DeviceManagerProtocol],isTimeOut: Bool, error: NSError?) -> Void in
            complete(devices,isTimeOut, error)
        }
    }
    
    func startScaleInputData(_ weight: Float, waterContent: Float, visceralFatContent: Float) -> ScaleResultProtocol {
        
        return MyBodyManager.scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: UserManager.sharedInstance.currentUser.gender, userId: UserManager.sharedInstance.currentUser.userId, age: UserManager.sharedInstance.currentUser.age, height: UserManager.sharedInstance.currentUser.height)
    }
    
    func addTestDatas() {
        for _ in 41...0 {
            let weight = 60 + arc4random() % 10
            let waterPercentage = 55 + arc4random() % 11
            let visceralFatContent = 10 + arc4random() % 10
            
            let result = startScaleInputData(Float(weight), waterContent: Float(waterPercentage), visceralFatContent: Float(visceralFatContent))
            
            DBManager.sharedInstance.addEvaluationData(result)
        }
    }
    
    func setCheckStatusBlock(_ complete: @escaping (BluetoothStatus) -> Void) {
        BluetoothManager.shareInstance.setCheckStatusBlock(complete)
    }
    
    // 开始测量秤
    func startScale(_ complete: @escaping (_ info: ScaleResultProtocol?, _ isTimeOut: Bool, _ error: NSError?) -> Void) {
        
        BluetoothManager.shareInstance.scanDevice([DeviceType.myBody, DeviceType.myBodyMini, DeviceType.myBodyPlus]) { (devices: [DeviceManagerProtocol], isTimeOut: Bool, error: NSError?) -> Void in
            
            if error == nil {
                if devices.count > 0 {
                    let userModel = UserManager.sharedInstance.currentUser
                    let device = devices.first!
                    BluetoothManager.shareInstance.fire(device.uuid, info: ["userModel" : userModel], complete: { (result: ResultProtocol?, isTimeOut: Bool, error: NSError?) -> Void in
                        if error == nil {
                            if let braceletResult = result as? ScaleResultProtocol {
                                
                                // 存数据库
                                DBManager.sharedInstance.addEvaluationData(braceletResult)
                                
                                self.updateEvaluationData()
                            }
                        }
                        complete(result as? ScaleResultProtocol,isTimeOut, error)
                    })
                }
            }
            else {
                complete(nil,isTimeOut, error)
            }
        }
    }
    
    // 访客测量
    func visitorStartScale(_ user: UserModel, complete: @escaping (_ info: ScaleResultProtocol?,_ isTimeOut: Bool, _ error: NSError?) -> Void) {
        BluetoothManager.shareInstance.scanDevice([DeviceType.myBody, DeviceType.myBodyMini, DeviceType.myBodyPlus]) { (devices: [DeviceManagerProtocol],isTimeOut: Bool, error: NSError?) -> Void in
            
            if error == nil {
                if devices.count > 0 {
                    let device = devices.first!
                    BluetoothManager.shareInstance.fire(device.uuid, info: ["userModel" : user], complete: { (result: ResultProtocol?,isTimeOut: Bool, error: NSError?) -> Void in
                        if error == nil {
                            if let braceletResult = result as? ScaleResultProtocol {
                                
                                // 存数据库
                                DBManager.sharedInstance.addEvaluationData(braceletResult)
                            }
                        }
                        complete(result as? ScaleResultProtocol,isTimeOut, error)
                    })
                }
            }
            else {
                complete(nil,isTimeOut, error)
            }
        }
    }
    
    static func mouthDaysDatas(_ beginTimescamp: Date, endTimescamp: Date) -> [[String: AnyObject]] {
        return DBManager.sharedInstance.queryCountEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp, userId: UserManager.sharedInstance.currentUser.userId, count: 5)
    }
    
    static func checkAndSyncEvaluationDatas(_ userId: Int, complete: @escaping (NSError?) -> Void) {
        
        var user: UserModel? = nil
        if userId == UserData.sharedInstance.userId {
            user = UserModel(userId: userId, age: UserData.sharedInstance.age!, gender: UserData.sharedInstance.gender!, height: UserData.sharedInstance.height!, name: UserData.sharedInstance.name!, headURL: nil)
        }
        else if let userInfo = DBManager.sharedInstance.queryUser(userId) {
            user = UserModel(info: userInfo)
        }
        
        if user != nil {
            // 看是否需要获取历史信息
            let lastInfo = DBManager.sharedInstance.queryLastEvaluationData(userId)
            
            if lastInfo == nil {
                EvaluationRequest.queryEvaluationDatas(userId, startDate: Date(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: Date(), complete: { (datas, error: NSError?) -> Void in
                    
                    if error == nil {
                        var results: [ScaleResultProtocol] = []
                        
                        for data in datas! {
                            var info = data;
                            let fatPercentage = (data["fatPercentage"] as! NSNumber).floatValue
                            info["fatPercentage"] = NSNumber(value: fatPercentage * 100 as Float)
                            results.append(ScaleResultProtocolCreate(info, gender: user!.gender, age: user!.age, height: user!.height))
                        }
                        
                        DBManager.sharedInstance.addEvaluationDatas(results, isUpload: true)
                    }
                    
                    complete(error)
                })
            }
            else {
                complete(nil)
            }
        }
        else {
            complete(NSError(domain: "EvaluationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "未找到用户"]))
        }
        
    }
    
    static func checkAndSyncEvaluationDatas(_ complete: @escaping (NSError?) -> Void) {
        
        let users = DBManager.sharedInstance.queryAllUser()
        for userInfo in users {
            let user = UserModel(info: userInfo)
            self.checkAndSyncEvaluationDatas(user.userId, complete: { (error: NSError?) -> Void in
                // nothing
            })
        }
        
        self.checkAndSyncEvaluationDatas(UserData.sharedInstance.userId!, complete: complete)
    }
    
    func updateEvaluationData() {
        // 获取所有没上传的数据
        let datas = DBManager.sharedInstance.queryNoUploadEvaluationDatas()
        
        var uploadDatas: [[String : AnyObject]] = []
        for info in datas {
            let gender: Bool
            let age: UInt8
            let height: UInt8
            let userId = (info["userId"] as! NSNumber).intValue
            if let userInfo = DBManager.sharedInstance.queryUser(userId) {
                gender = (userInfo["gender"] as! NSNumber).boolValue
                age = (userInfo["age"] as! NSNumber).uint8Value
                height = (userInfo["height"] as! NSNumber).uint8Value
            }
            else {
                gender = UserManager.mainUser.gender
                age = UserManager.mainUser.age
                height = UserManager.mainUser.height
            }
            
            let result = ScaleResultProtocolCreate(info, gender: gender, age: age, height: height)
            uploadDatas.append(result.uploadInfo((info["timeStamp"] as! Date).secondTimeInteval()))
        }
        
        // 上传
        EvaluationRequest.uploadEvaluationDatas(UserManager.mainUser.userId, datas: uploadDatas) { (info, error: NSError?) -> Void in
            if error == nil {
                // 更新数据
                DBManager.sharedInstance.updateUploadEvaluationDatas(info!)
                
                // 删除一月前数据
                DBManager.sharedInstance.deleteEvaluationDatas(Date(timeIntervalSinceNow: -31 * 24 * 60 * 60))
            }
        }
    }
    
    func deleteEvaluationData(_ result: ScaleResultProtocol, complete: @escaping (NSError?) -> Void) {
        
        EvaluationRequest.deleteEvaluationData(result.dataId, userId: result.userId) { (error: NSError?) -> Void in
            if error == nil {
                DBManager.sharedInstance.deleteEvaluationData(result.dataId,userId: result.userId)
            }
            complete(error)
        }
        
    }
    
    func share(_ shareType: ShareType, image: UIImage, complete: @escaping (NSError?) -> Void) {
        ShareSDKHelper.shareImage(shareType, image: image, isEvaluation: false) { (error: NSError?) -> Void in
            
            if error == nil {
                let platformType: ThirdPlatformType
                if shareType == ShareType.qqFriend {
                    platformType = ThirdPlatformType.QQ
                }
                else if shareType == ShareType.weiBo {
                    platformType = ThirdPlatformType.Weibo
                }
                else {
                    platformType = ThirdPlatformType.WeChat
                }
                
                ScoreRequest.share(UserData.sharedInstance.userId!, type: 1, platform: platformType, complete: { (error: NSError?) -> Void in
                    
                    if error == nil {
                        DBManager.sharedInstance.addShareData(shareType.rawValue)
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
