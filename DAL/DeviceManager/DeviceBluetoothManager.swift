//
//  DeviceBluetoothManager.swift
//  Health
//
//  Created by Yalin on 15/9/4.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class DeviceBluetoothManager: NSObject {
    private var centralManager: CBCentralManager
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    private var receiveData: NSMutableData = NSMutableData()
    
    let oldScaleUUID = "956FE402-B077-F944-0D7E-71991C19A2A6"
    let oldScaleServiceUUID = "F433BD80-75B8-11E2-97D9-0002A5D5C51B"
    let oldScaleWriteCharacteristicsUUID = "29F11080-75B9-11E2-8BF6-0002A5D5C51B"
    let oldScaleNofityCharacteristicsUUID = "1A2EA400-75B9-11E2-BE05-0002A5D5C51B"
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func connect(peripheral: CBPeripheral) {
        centralManager.delegate = self
        centralManager.connectPeripheral(self.peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
    }
    
    func scale() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
}

extension DeviceBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("CentralManager is initialized")
        switch central.state {
        case CBCentralManagerState.Unauthorized:
            println("The app is not authorized to use Bluetooth low energy.")
        case CBCentralManagerState.PoweredOff:
            println("Bluetooth is currently powered off.")
        case CBCentralManagerState.PoweredOn:
            println("Bluetooth is currently powered on and available to use.")
            
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        default:
            break
            
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println("--------------------------------- %s",__FUNCTION__)
        
        println("CenCentalManagerDelegate didDiscoverPeripheral")
        println("Discovered \(peripheral)")
        println("Rssi: \(RSSI)")
        println("advertisementData: \(advertisementData)")
        
        println("Stop scan the Ble Devices")
        
        if peripheral.identifier.UUIDString == oldScaleUUID {
            // 老款秤
            self.peripheral = peripheral
            connect(self.peripheral!)
            centralManager.stopScan()
        }
        
//        if peripheral.name != nil && peripheral.name == "Fastfox-Lite" {
//            self.peripheral = peripheral
//            connect(self.peripheral!)
//            centralManager.stopScan()
//        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // 连接上 外设  开始查找服务
        NSLog("Did connect to peripheral: %@", peripheral);
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        NSLog("connect peripheral error: %@", error)
    }
}

// 外设手环服务
extension DeviceBluetoothManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error == nil {
            
            for service: CBService in self.peripheral!.services as! [CBService] {
                if service.UUID == CBUUID(string: oldScaleServiceUUID) {
                    peripheral.discoverCharacteristics(nil, forService: service)
                    break
                }
            }
        }
        else {
            // 调用失败代理
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if error == nil {
            for characteristic: CBCharacteristic in service.characteristics as! [CBCharacteristic] {
                if characteristic.UUID == CBUUID(string: oldScaleWriteCharacteristicsUUID) {
                    // 写入 任务数据数据字符
                    
                    let data = ScaleOldUserFormat().toData()
                    self.peripheral?.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                else if characteristic.UUID == CBUUID(string: oldScaleNofityCharacteristicsUUID) {
                    // 读数据字符
                    self.characteristic = characteristic
                    self.peripheral?.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
        else {
            // 调用失败代理
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("接收到数据: \(characteristic.value)")
        
        if error == nil {
            decodeData(characteristic.value)
        }
        else {
            // 调用失败代理
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            NSLog("%@", error)
            // 调用失败代理
        }
    }
}

extension DeviceBluetoothManager {
    func decodeData(data :NSData) {
        
        if receiveData.length == 0 {
            // 第一次接收数据
//            currentFormate = BraceletBlueToothFormats(data: data)
        }
        
        receiveData.appendData(data)
        
//        if Int(currentFormate!.packageHead.nLength) == receiveData.length {
//            
//            currentFormate!.setBodyData(receiveData)
//            receiveData.setData(NSData())
//            
//            if currentFormate!.packageHead.nCmdId == 10002 {
//                if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.requestTimeCmdId {
//                    // 时间请求包
//                    var formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId)
//                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
//                }
//                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
//                    // 收到运动数据 可以结束了?
//                    println("\(currentFormate)")
//                    
//                    self.centralManager.cancelPeripheralConnection(self.peripheral!)
//                    self.peripheral = nil
//                    self.characteristic = nil
//                }
//                else if currentFormate!.packageBody?.cmd_type == 13 {
//                    
//                }
//            }
//        }
    }
}
