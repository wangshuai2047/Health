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
    var RSSI = NSNumber(value: 0 as Int)
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    var type: DeviceType = DeviceType.bracelet
    
    var serviceUUID: String { return "FFF0" }
    var characteristicUUID: [String] { return ["FFF2"] }
    
    fileprivate var currentFormate: BraceletBlueToothFormats?
    fileprivate var result: BraceletResult?  // 同步运动数据
    
    fileprivate var user: UserModel?
    
    var fireComplete: ((ResultProtocol?, NSError?) -> Void)?
    
    init(name setName: String, uuid setUUID: String, peripheral setPeripheral: CBPeripheral?, characteristic setCharacteristic: CBCharacteristic?) {
        name = setName
        uuid = setUUID
        peripheral = setPeripheral
        characteristic = setCharacteristic
        super.init()// Use of 'self' in delegating initializer before self.init is called
    }
    
    var receiveDatas: NSMutableData = NSMutableData()
    
    fileprivate func reveiveData(_ data: Data) {
        if receiveDatas.length == 0 {
            // 第一次接收数据
            currentFormate = BraceletBlueToothFormats(data: data)
        }
        
        receiveDatas.append(data)
        
        if Int(currentFormate!.packageHead.nLength) == receiveDatas.length {
            
            currentFormate!.setBodyData(receiveDatas as Data)
            receiveDatas.setData(Data())
            
            if currentFormate!.packageHead.nCmdId == 10002 {
                
                
                if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.requestTimeCmdId {
                    
                    result?.results.removeAll()
                    // 时间请求包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId, time: Date())
                    self.peripheral!.writeValue(formats.toData(), for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    receiveDatas.setData(Data())
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
                    // 收到运动数据
                    print("\(currentFormate)")
                    
                    result?.results += dealSuccessData()
                    
                    // 发送运动反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.sportCmdId, time: Date())
                    self.peripheral!.writeValue(formats.toData(), for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    
                    receiveDatas.setData(Data())
                    
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.generalCmdId {
                    //收到设备信息
                    if let bodyPackage = currentFormate?.packageBody as? BraceletDeviceVersionReqPackageBody {
                        result?.firm_ver = bodyPackage.firm_ver
                        result?.device_model = bodyPackage.device_model
                    }
                    
                    // 发送通用反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.generalCmdId, time: Date())
                    self.peripheral!.writeValue(formats.toData(), for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    
                    receiveDatas.setData(Data())
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
                let result = BraceletData(userId: user!.userId, startTime: startTime, endTime: data.end_time, steps: data.steps, stepsType: data.stepsType)
                list.append(result)
                startTime = data.end_time
            }
        }
        
        return list
    }
    
    func fire(_ info: [String : Any], complete: @escaping (ResultProtocol?, Error?) -> Void) {
        if let user = info["userModel"] as? UserModel {
            self.user = user
        }
        fireComplete = complete
        receiveDatas.setData(Data())
        result = BraceletResult()
    }
}

extension BraceletManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 连接上 外设  开始查找服务
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        fireComplete?(nil, error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        fireComplete?(nil, error as NSError?)
    }
}

// 外设手环服务
extension BraceletManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil && self.peripheral!.services != nil {
            
        }
        else {
            // 调用失败代理
            fireComplete?(nil, error as NSError?)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil && service.characteristics != nil {
            for char in service.characteristics! {
                print("\(char)")
                if char.uuid == CBUUID(string: "FFF1") || char.uuid == CBUUID(string: "FFF2") {
                    self.characteristic = char
                    self.peripheral!.setNotifyValue(true, for: self.characteristic!)
//                    break
                }
            }
        }
        else {
            // 调用失败代理
            NSLog("didDiscoverCharacteristicsForService error \(error!)")
            fireComplete?(nil, error as? NSError)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error == nil && characteristic.value != nil {
//            print("接收到数据: \(characteristic.value)")
            reveiveData(characteristic.value!)
        }
        else {
            // 调用失败代理
            NSLog("didUpdateValueForCharacteristic error \(error!)")
            fireComplete?(nil, error as? NSError)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            NSLog("didWriteValueForCharacteristic \(error!)")
            // 调用失败代理
            fireComplete?(nil, error as? NSError)
        }
    }
}
