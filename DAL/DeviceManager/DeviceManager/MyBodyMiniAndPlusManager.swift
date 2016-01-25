//
//  MyBodyMiniManager.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreBluetooth

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
        
        var firstBuffer: UInt8 = 0
        data.getBytes(buffer: &firstBuffer, range: NSRange(location: 0, length: 1))
        if firstBuffer == 0xBC {
            let format = MybodyMiniAndPlusBlueToothFormats(data: data)
            if format.cmd == MybodyMiniAndPlusBlueToothFormats.CMD.weightData {
                // 已收到称重数据
                // 新称获取到的体重的值，原本是两位小数，不要做四舍五入，直接把最后一位小数舍去。
                let weight: Float = Float(Int(format.weight * 10) / 10)
                self.result?.weight = weight
                
                let receiveWeightData = MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.receiveWeightData).toReceiveWeightData()
                NSLog("write receiveWeightData : \(receiveWeightData)")
                self.peripheral?.writeValue(receiveWeightData, forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
            }
            else if format.cmd == MybodyMiniAndPlusBlueToothFormats.CMD.bodyData {
                
                // 判断测试是否成功
                var error: NSError? = nil
                if format.resultCode == 0x33 {
                    // 测试失败
                    error = NSError(domain: "MyBodyMiniAndPlusManager", code: 99, userInfo: [NSLocalizedDescriptionKey : "请重新测试"])
                }
                else {
                    self.result?.setDatas(format.datas)
                    self.result?.hepaticAdiposeInfiltration = true
                    
                    let receiveBodyData = MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.receiveBodyData).toReceiveBodyData()
                    NSLog("write receiveBodyData : \(receiveBodyData)")
                    self.peripheral?.writeValue(receiveBodyData, forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
                }
                
                fireComplete?(result, error)
            }
        }
        else {
            dispatch_after(1, dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
            })
//            fireComplete?(nil, NSError(domain: "评测错误", code: 1, userInfo: [NSLocalizedDescriptionKey : "BodyMini 返回的数据格式错误,无法解析"]))
        }
    }
}

extension MyBodyMiniAndPlusManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        fireComplete?(nil, error)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        fireComplete?(nil, error)
    }
}

extension MyBodyMiniAndPlusManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        NSLog("search service UUID %@", service.characteristics!)
        if error == nil && service.characteristics != nil {
            for characteristic in service.characteristics! {
                
                if CBUUID(string: "BCA1") == characteristic.UUID {
                    self.readCharacteristic = characteristic
//                    self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
//                    self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
//                    self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
                    
//                    dispatch_after(dispatch_time_t(1), dispatch_get_main_queue(), { [unowned self] () -> Void in
//                        
//                        if self.readCharacteristic?.properties == CBCharacteristicProperties.Notify {
//                            self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
//                        }
//                        
//                    })
                }
                else if CBUUID(string: "BCA2") == characteristic.UUID {
                    self.writeCharacteristic = characteristic
                    if let userModel = fireInfo?["userModel"] as? UserModel {
//                        self.peripheral?.setNotifyValue(true, forCharacteristic: self.writeCharacteristic!)
                        
//                        dispatch_after(dispatch_time_t(1), dispatch_get_main_queue(), { [unowned self] () -> Void in
                        let setUserData = MybodyMiniAndPlusBlueToothFormats(cmd: MybodyMiniAndPlusBlueToothFormats.CMD.setUserData).toSetUserData(userModel.gender, age: userModel.age, height: userModel.height)
                        NSLog("write user data: %@", setUserData)
                            self.peripheral?.writeValue(setUserData, forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
                        
                            
//                        })
                        
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
            NSLog("接收到数据: \(characteristic.value)")
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
            print("write char: \(self.writeCharacteristic)")
            print("read char: \(self.readCharacteristic)")
            
//            self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
//            fireComplete?(nil, error)
            dispatch_after(dispatch_time_t(1), dispatch_get_main_queue(), { [unowned self] () -> Void in
//                self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
                self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
            })
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didUpdateNotificationStateForCharacteristic \(error)")
    }
}