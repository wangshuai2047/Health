//
//  BraceletManager.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreBluetooth

class BraceletManager: NSObject, DeviceManagerProtocol {
    var name: String
    var uuid: String
    var RSSI = NSNumber(integer: 0)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.Bracelet
    
    var serviceUUID: String { return "FFF0" }
    var characteristicUUID: [String] { return ["FFF2"] }
    
    private var currentFormate: BraceletBlueToothFormats?
    private var result: BraceletResult?  // 同步运动数据
    
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    var receiveDatas: NSMutableData = NSMutableData()
    
    private func reveiveData(data: NSData) {
        if receiveDatas.length == 0 {
            // 第一次接收数据
            currentFormate = BraceletBlueToothFormats(data: data)
        }
        
        receiveDatas.appendData(data)
        
        if Int(currentFormate!.packageHead.nLength) == receiveDatas.length {
            
            currentFormate!.setBodyData(receiveDatas)
            receiveDatas.setData(NSData())
            
            if currentFormate!.packageHead.nCmdId == 10002 {
                
                
                if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.requestTimeCmdId {
                    
                    result?.results.removeAll()
                    // 时间请求包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    receiveDatas.setData(NSData())
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
                    // 收到运动数据
                    print("\(currentFormate)")
                    
                    result?.results += dealSuccessData()
                    
                    // 发送运动反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.sportCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    
                    receiveDatas.setData(NSData())
                    
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.generalCmdId {
                    //收到设备信息
                    if let bodyPackage = currentFormate?.packageBody as? BraceletDeviceVersionReqPackageBody {
                        result?.firm_ver = bodyPackage.firm_ver
                        result?.device_model = bodyPackage.device_model
                    }
                    
                    // 发送通用反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.generalCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    
                    receiveDatas.setData(NSData())
                }
                else if currentFormate?.packageBody?.cmd_type == BraceletBlueToothFormats.batteryCmdId {
                    // 收到电量数据 可以结束了
                    if let p = (currentFormate?.packageBody as? BraceletBatteryReqPackageBody)?.percent {
                        result?.percent = p
                    }
                    
                    fireComplete?(result, nil)
                    result?.results.removeAll()
                }
            }
        }
    }
    
    func dealSuccessData() -> [BraceletData] {
        var list: [BraceletData] = []
        
        if let bodyData = currentFormate?.packageBody as? BraceletSportReqPackageBody {
            var startTime = bodyData.start_time
            
            for data in bodyData.info {
                let result = BraceletData(userId: UserData.shareInstance().userId!, startTime: startTime, endTime: data.end_time, steps: data.steps, stepsType: data.stepsType)
                list.append(result)
                startTime = data.end_time
            }
        }
        
        return list
    }
    
    func fire(info: [String : Any], complete: (ResultProtocol?, NSError?) -> Void) {
        fireComplete = complete
        receiveDatas.setData(NSData())
        result = BraceletResult()
    }
}

extension BraceletManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // 连接上 外设  开始查找服务
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        fireComplete?(nil, error)
    }
}

// 外设手环服务
extension BraceletManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error == nil && self.peripheral!.services != nil {
            
        }
        else {
            // 调用失败代理
            fireComplete?(nil, error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error == nil && service.characteristics != nil {
            for char in service.characteristics! {
                print("\(char)")
                if char.UUID == CBUUID(string: "FFF1") || char.UUID == CBUUID(string: "FFF2") {
                    self.characteristic = char
                    self.peripheral!.setNotifyValue(true, forCharacteristic: self.characteristic!)
//                    break
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
    }
}