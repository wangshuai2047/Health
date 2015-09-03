//
//  BraceletManager.swift
//  Health
//
//  Created by Yalin on 15/8/18.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class BraceletManager: NSObject {
    
    private var centralManager: CBCentralManager
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    private var receiveData: NSMutableData = NSMutableData()
    private var currentFormate: BraceletBlueToothFormats?
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(peripheral: CBPeripheral) {
        centralManager.delegate = self
        centralManager.connectPeripheral(self.peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
    }
}

extension BraceletManager: BraceletProtocol {
    func syncData() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
//        centralManager.scanForPeripheralsWithServices([CBUUID(string: "4588E96E-AE96-1950-FB77-9D76F3284961"), CBUUID(string: "FFF0"),CBUUID(string: "FFF1"),CBUUID(string: "FFF2")], options: nil)
    }
}

extension BraceletManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("CentralManager is initialized")
        switch central.state {
        case CBCentralManagerState.Unauthorized:
            println("The app is not authorized to use Bluetooth low energy.")
        case CBCentralManagerState.PoweredOff:
            println("Bluetooth is currently powered off.")
        case CBCentralManagerState.PoweredOn:
            println("Bluetooth is currently powered on and available to use.")
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
        
        if peripheral.name != nil && peripheral.name == "Fastfox-Lite" {
            self.peripheral = peripheral
            connect(self.peripheral!)
            centralManager.stopScan()
        }
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
extension BraceletManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error == nil {
            
            for service: CBService in self.peripheral!.services as! [CBService] {
                if service.UUID == CBUUID(string: "FFF0") {
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
                if characteristic.UUID == CBUUID(string: "FFF1") || characteristic.UUID == CBUUID(string: "FFF2") {
                    
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

extension BraceletManager {
    func decodeData(data :NSData) {
        
        if receiveData.length == 0 {
            // 第一次接收数据
            currentFormate = BraceletBlueToothFormats(data: data)
        }
        
        receiveData.appendData(data)
        
        if Int(currentFormate!.packageHead.nLength) == receiveData.length {
            
            currentFormate!.setBodyData(receiveData)
            receiveData.setData(NSData())
            
            if currentFormate!.packageHead.nCmdId == 10002 {
                if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.requestTimeCmdId {
                    // 时间请求包
                    var formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId)
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
                    // 收到运动数据 可以结束了?
                    println("\(currentFormate)")
                    
                    self.centralManager.cancelPeripheralConnection(self.peripheral!)
                    self.peripheral = nil
                    self.characteristic = nil
                }
                else if currentFormate!.packageBody?.cmd_type == 13 {
                    
                }
            }
        }
    }
}
