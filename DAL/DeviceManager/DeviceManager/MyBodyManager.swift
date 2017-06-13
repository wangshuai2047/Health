//
//  MyBodyManager.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyBodyManager: NSObject, DeviceManagerProtocol {
    
    internal func fire(_ info: [String : Any], complete: @escaping (ResultProtocol?, Error?) -> Void) {
        self.fireComplete = complete
        self.fireInfo = info
        
        if let userModel = fireInfo?["userModel"] as? UserModel {
            VScaleManager.sharedInstance().setCalulateDataWithUserID(110, gender: userModel.gender ? 0 : 1, age: userModel.age, height: userModel.height)
            VScaleManager.sharedInstance().scanDevice({ [unowned self] (error: Error?) -> Void in
                if error == nil {
                    VScaleManager.sharedInstance().scale({ [unowned self] (result: VTFatScaleTestResult?, error: Error?) -> Void in
                        // 生成 resultProtocol 对象
                        if error == nil {
                            
                            let scaleResult = MyBodyManager.scaleInputData(result!.weight, waterContent: result!.waterContent, visceralFatContent: Float(result!.visceralFatContent), gender: userModel.gender, userId: userModel.userId, age: userModel.age, height: userModel.height)
                            self.fireComplete?(scaleResult, error as NSError?)
                        }
                        else {
                            self.fireComplete?(nil, error as NSError?)
                        }
                        })
                }
                else {
                    self.fireComplete?(nil, error as NSError?)
                }
                
                VScaleManager.sharedInstance().disconnect()
                })
            
        }
        else {
            print("MyBodyManager fire error: info参数不对 没有userModel字段")
            fireComplete?(nil, NSError(domain: "MyBodyManager fire error", code: 0, userInfo: [NSLocalizedDescriptionKey:"fire info参数不对 没有userModel字段"]))
        }
    }


    var name: String
    var uuid: String
    var RSSI = NSNumber(value: 0 as Int)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.myBody
    
    var serviceUUID: String { return "" }
    var characteristicUUID: [String] { return [] }
    
    var fireInfo: [String : Any]?
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    func transformResult(_ result: VTFatScaleTestResult) -> ScaleResultProtocol {
        
        let userModel = fireInfo?["userModel"] as! UserModel
        
        return MyBodyManager.scaleInputData(result.weight, waterContent: result.waterContent, visceralFatContent: Float(result.visceralFatContent), gender: userModel.gender, userId: userModel.userId, age: userModel.age, height: userModel.height)
    }
    
    static func scaleInputData(_ weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol {
        
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
//        let boneMuscleWeight = muscleWeight * 0.7135

        var boneMuscleWeight:Float!
        if gender  == true{//男
            boneMuscleWeight = (muscleWeight - 0.4) * 0.7135
        } else {//女
            boneMuscleWeight = (muscleWeight - 1.5) * 0.7135
        }
        
        let result = MyBodyResult(userId: userId, gender: gender, age: age, height: height, weight: weight, waterContent: waterContent, visceralFatContent: visceralFatContent, fatPercentage: fatPercentage, fatWeight: fatWeight, waterWeight: waterWeight, muscleWeight: muscleWeight, proteinWeight: proteinWeight, boneWeight: boneWeight, boneMuscleWeight: boneMuscleWeight)
        
        return result
    }
}

extension MyBodyManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}

extension MyBodyManager: CBPeripheralDelegate {
    
}
