//
//  MyBodyManager.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class MyBodyManager: NSObject, DeviceManagerProtocol {
    var name: String
    var uuid: String
    var RSSI = NSNumber(integer: 0)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.MyBody
    
    var serviceUUID: String { return "" }
    var characteristicUUID: [String] { return [] }
    
    var fireInfo: [String : Any]?
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void) {
        self.fireComplete = complete
        self.fireInfo = info
        
        if let userModel = fireInfo?["userModel"] as? UserModel {
            VScaleManager.sharedInstance().setCalulateDataWithUserID(110, gender: userModel.gender ? 0 : 1, age: userModel.age, height: userModel.height)
            self.result = MyBodyMiniAndPlusResult(dataId: NSUUID().UUIDString, userId: userModel.userId, gender: userModel.gender, age: userModel.age, height: userModel.height)
        }
        else {
            print("MyBodyManager fire error: info参数不对 没有userModel字段")
            fireComplete?(nil, NSError(domain: "MyBodyManager fire error", code: 0, userInfo: [NSLocalizedDescriptionKey:"fire info参数不对 没有userModel字段"]))
        }
    }
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
}

extension MyBodyManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
}

extension MyBodyManager: CBPeripheralDelegate {
    
}