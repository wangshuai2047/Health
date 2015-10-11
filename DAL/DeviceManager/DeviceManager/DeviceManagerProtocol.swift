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
    var peripheral: CBPeripheral? { get set }
    var characteristic: CBCharacteristic? { get set }
    var type: DeviceType { get set }
    
    func fire(info: [String : AnyObject], complete: (ResultProtocol?, NSError?) -> Void)
}