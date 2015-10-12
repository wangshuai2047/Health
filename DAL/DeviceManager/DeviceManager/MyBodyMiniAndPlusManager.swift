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
    
    var serviceUUID: String { return "" }
    var characteristicUUID: [String] { return [] }
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void) {
        
    }
    
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
}

extension MyBodyMiniAndPlusManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
}

extension MyBodyMiniAndPlusManager: CBPeripheralDelegate {
    
}