//
//  DeviceManagerProtocol.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

protocol DeviceManagerProtocol: CBCentralManagerDelegate, CBPeripheralDelegate {
    var name: String { get set }
    var uuid: String { get set }
    var RSSI: NSNumber { get set }
    var peripheral: CBPeripheral? { get set }
    var characteristic: CBCharacteristic? { get set }
    var type: DeviceType { get set }
    var serviceUUID: String { get }
    var characteristicUUID: [String] { get }
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void)
}