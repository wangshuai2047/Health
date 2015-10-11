//
//  ScaleOld.swift
//  Health
//
//  Created by Yalin on 15/8/29.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class ScaleOld: NSObject {
    
    var vscaleManager: VScaleManager?
    class func shareInstance() -> ScaleOld {
        struct Singleton {
            static var predicate: dispatch_once_t = 0
            static var instance: ScaleOld? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            Singleton.instance = ScaleOld()
        })
        
        return Singleton.instance!
    }
    
    override init() {
        super.init()
    }
    
    var delegate: ScaleDelegate?
    
    var isScaning: Bool = false
    var isScaling: Bool = false
    
    var userId: Int?
    var gender: Bool?
    var height: UInt8?
    var age: UInt8?
    
    func transformResult(result: VTFatScaleTestResult) -> ScaleResultProtocol {
        return ScaleOld.scaleInputData(result.weight, waterContent: result.waterContent, visceralFatContent: Float(result.visceralFatContent), gender: gender!, userId: userId!, age: age!, height: height!)
    }
}

extension ScaleOld: ScaleProtocol {
    var isConnectDevice: Bool {
        return vscaleManager!.curStatus == VCStatus.Connected
    }
    
    func scanDevice(complete: ((scale: ScaleProtocol) -> Void)) {
        isScaning = true
        vscaleManager!.scanDevice {[unowned self] (error: NSError?) -> Void in
            if error == nil && self.isScaning {
                self.delegate?.scanDevice(self)
                complete(scale: self)
            }
            self.isScaning = false
        }
    }
    
    func scanCancel() {
        isScaning = false
    }
    
    func setScaleData(userId: Int, gender: Bool, age: UInt8, height: UInt8) {
        
        self.userId = userId
        self.gender = gender
        self.age = age
        self.height = height
        
        if vscaleManager == nil {
            vscaleManager = VScaleManager()
            vscaleManager?.delegate = self
        }
        
        vscaleManager!.setCalulateDataWithUserID(1, gender: gender ? 0 : 1, age: age, height: height)
    }
    
    func startScale(complete: (result: ScaleResultProtocol?, err: NSError?) -> Void) {
        
        if vscaleManager == nil {
            vscaleManager = VScaleManager()
            vscaleManager?.delegate = self
        }
        
        scanDevice {[unowned self] (scale) -> Void in
            
            self.isScaling = true
            self.vscaleManager!.scale {[unowned self] (result: VTFatScaleTestResult!, err: NSError!) -> Void in
                if self.isScaling && err == nil {
                    // 转化计算数据
                    complete(result: self.transformResult(result), err: nil)
                }
                
                DBManager.shareInstance().addDevice(self.vscaleManager!.deviceUUID, name: self.vscaleManager!.name, type: DeviceType.MyBody)
                
                self.vscaleManager = nil
                self.isScaling = false
            }
        }
    }
    
    static func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol {
        
        /*
        从四点极称中，我们只需要三项数据：水分率、内脏脂肪率和体重
        水分率为a%，体脂率为p%，体重为W，身高为h，年龄为age
        身体评分和身体年龄的公式已经给
        
        体脂率（男）       p% =（1-((a%*100)/73.81)+(0.6/W)）*100-1
        女               p% =（1-((a%*100)/73.81)+(0.6/W)）*100+1
        
        脂肪重 F=W*p%
        水分重 a=W*a%
        肌肉重 S=a/0.78
        蛋白质重 M=S-a
        骨重 B=W-F-S
        */
        
        let gender = UserData.shareInstance().gender!
        
        // 体脂率
        var fatPercentage = (1 - ((waterContent)/73.81) + (0.6 / weight)) * 100 - 1 // 男
        if gender == false {
            fatPercentage += 2 // 女
        }
        
        // 脂肪重
        let fatWeight = weight * fatPercentage / 100
        // 水分重
        let waterWeight = weight * waterContent / 100
        // 肌肉重
        let muscleWeight = waterWeight / 0.78
        // 蛋白质重
        let proteinWeight =  muscleWeight - waterWeight
        // 骨重
        let boneWeight = weight - fatWeight - muscleWeight
        // 骨骼肌重
        let boneMuscleWeight = muscleWeight * 0.7135
        
        let result = MyBodyResult(userId: userId, gender: gender, age: age, height: height, weight: weight, waterContent: waterContent, visceralFatContent: visceralFatContent, fatPercentage: fatPercentage, fatWeight: fatWeight, waterWeight: waterWeight, muscleWeight: muscleWeight, proteinWeight: proteinWeight, boneWeight: boneWeight, boneMuscleWeight: boneMuscleWeight)
        
        return result
    }
    
    func stopScale() {
        isScaling = false
    }
}

extension ScaleOld: VScaleManagerDelegate {
    func updateDeviceStatus(status: VCStatus) {
        print("updateDeviceStatus \(status.rawValue)", terminator: "")
    }
    
    func updateUIDataWithFatScale(result: VTFatScaleTestResult!) {
        
    }
    
    func updateUIDataWithWeightScale(result: VTScaleTestResult!) {
        
    }
}