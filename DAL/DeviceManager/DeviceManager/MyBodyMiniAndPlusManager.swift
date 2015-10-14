//
//  MyBodyMiniManager.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class MyBodyMiniAndPlusManager: NSObject, DeviceManagerProtocol {
    var name: String
    var uuid: String
    var RSSI = NSNumber(integer: 0)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.MyBodyMini
    
    var serviceUUID: String { return "BCA0" }
    var characteristicUUID: [String] { return ["BCA1", "BCA2"] }
    
    var result: MyBodyMiniAndPlusResult?
    
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    
    var fireInfo: [String : Any]?
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void) {
        self.fireComplete = complete
        self.fireInfo = info
        
        if let userModel = fireInfo?["userModel"] as? UserModel {
            self.result = MyBodyMiniAndPlusResult(dataId: NSUUID().UUIDString, userId: userModel.userId, gender: userModel.gender, age: userModel.age, height: userModel.height)
        }
        else {
            print("MyBodyMiniAndPlusManager fire error: info参数不对 没有userModel字段")
            fireComplete?(nil, NSError(domain: "MyBodyMiniAndPlusManager fire error", code: 0, userInfo: [NSLocalizedDescriptionKey:"fire info参数不对 没有userModel字段"]))
        }
    }
    
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    private func reveiveData(data: NSData) {
        let format = MybodyMiniAndPlusBlueToothFormats(data: data)
        if format.cmd == MybodyMiniAndPlusBlueToothFormats.CMD.weightData {
            // 已收到称重数据
            self.result?.weight = Float(format.weight)
            self.result?.hepaticAdiposeInfiltration = format.resultCode == 0x30 ? false : true
            
            self.peripheral?.writeValue(MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.receiveWeightData).toReceiveWeightData(), forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
        }
        else if format.cmd == MybodyMiniAndPlusBlueToothFormats.CMD.bodyData {
            self.result?.setDatas(format.datas)
            self.peripheral?.writeValue(MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.receiveBodyData).toReceiveBodyData(), forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
            
            fireComplete?(result, nil)
        }
    }
}

extension MyBodyMiniAndPlusManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
}

extension MyBodyMiniAndPlusManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        NSLog("search service UUID %@", service.characteristics!)
        if error == nil && service.characteristics != nil {
            for characteristic in service.characteristics! {
                
                if CBUUID(string: "BCA1") == characteristic.UUID {
                    self.readCharacteristic = characteristic
                    
                    self.peripheral?.setNotifyValue(true, forCharacteristic: characteristic)
                }
                else if CBUUID(string: "BCA2") == characteristic.UUID {
                    self.writeCharacteristic = characteristic
                    if let userModel = fireInfo?["userModel"] as? UserModel {
                        self.peripheral?.setNotifyValue(true, forCharacteristic: self.writeCharacteristic!)
                        
                        dispatch_after(dispatch_time_t(0.1), dispatch_get_main_queue(), { [unowned self] () -> Void in
                            self.peripheral?.writeValue(MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.setUserData).toSetUserData(userModel.gender, age: userModel.age, height: userModel.height), forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
                        })
                        print("write char: \(self.writeCharacteristic)")
                    }
                }
            }
            
            
        }
        else {
            // 调用失败代理
            NSLog("didDiscoverCharacteristicsForService error %@", error!)
            fireComplete?(nil, error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error == nil && characteristic.value != nil {
            print("接收到数据: \(characteristic.value)")
            reveiveData(characteristic.value!)
        }
        else {
            // 调用失败代理
            NSLog("didUpdateValueForCharacteristic error %@", error!)
            fireComplete?(nil, error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            NSLog("didWriteValueForCharacteristic %@", error!)
            // 调用失败代理
            fireComplete?(nil, error)
        }
        else {
            print("write char: \(self.readCharacteristic)")
            fireComplete?(nil, error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("\(error)")
    }
}