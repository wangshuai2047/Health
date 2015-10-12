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
    
    
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    
    var fireInfo: [String : Any]?
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void) {
        self.fireComplete = complete
        self.fireInfo = info
    }
    
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    private func reveiveData(data: NSData) {
        
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
//                        self.peripheral?.setNotifyValue(true, forCharacteristic: self.writeCharacteristic!)
//                        self.peripheral?.writeValue(MybodyMiniAndPlusBlueToothFormats.toSetUserData(MybodyMiniAndPlusBlueToothFormats.CMD.setUserData), forCharacteristic: self.writeCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
                        
                        print("write char: \(self.writeCharacteristic)")
                        
                    }
                }
            }
            
            
        }
        else {
            // 调用失败代理
            NSLog("didDiscoverCharacteristicsForService error %@", error!)
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
            self.peripheral?.setNotifyValue(true, forCharacteristic: self.readCharacteristic!)
//            self.peripheral?.readValueForCharacteristic(self.readCharacteristic!)
            print("write char: \(self.readCharacteristic)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("\(error)")
    }
}