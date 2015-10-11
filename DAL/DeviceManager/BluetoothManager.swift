//
//  BluetoothManager.swift
//  Health
//
//  Created by Yalin on 15/10/7.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

enum DeviceType: Int16 {
    case MyBody = 0
    case Bracelet
    case MyBodyMini
    case MyBodyPlus
    
    var AdvDataManufacturerData: NSData {
        
        // 新秤的设备ID
        // bc 01 84 08 42 6f 64 79 4d 69 6e 69 d4 c6 c8 d4
        var mybodyNewBuffer: [UInt8] = []
        mybodyNewBuffer.append(0xbc)
        mybodyNewBuffer.append(0x01)
        mybodyNewBuffer.append(0x84)
        mybodyNewBuffer.append(0x08)
        mybodyNewBuffer.append(0x42)
        mybodyNewBuffer.append(0x6f)
        mybodyNewBuffer.append(0x64)
        mybodyNewBuffer.append(0x79)
        mybodyNewBuffer.append(0x4d)
        mybodyNewBuffer.append(0x69)
        mybodyNewBuffer.append(0x6e)
        mybodyNewBuffer.append(0x69)
        mybodyNewBuffer.append(0xd4)
        mybodyNewBuffer.append(0xc6)
        mybodyNewBuffer.append(0xc8)
        mybodyNewBuffer.append(0xd4)
        let mybodyNewData = NSData(bytes: mybodyNewBuffer, length: mybodyNewBuffer.count)
        return mybodyNewData
        
        
        switch self {
        case .Bracelet:
            // a8 01 01 01 08 f4 06 a5 00 be 3f
            // a8 01 01 01 08 f4 06 a5 00 be 3f 01 0108f406 a500be3f
            var buffer: [UInt8] = []
            buffer.append(0xa8)
            buffer.append(0x01)
            buffer.append(0x01)
            buffer.append(0x01)
            buffer.append(0x08)
            buffer.append(0xf4)
            buffer.append(0x06)
            buffer.append(0xa5)
            buffer.append(0x00)
            buffer.append(0xbe)
            buffer.append(0x3f)
            
            let data = NSData(bytes: buffer, length: buffer.count)
            return data
        case .MyBody:
            return mybodyNewData
        case .MyBodyMini:
            return mybodyNewData
        case .MyBodyPlus:
            return mybodyNewData
        default:
            return NSData()
        }
    }
}

class BluetoothManager: NSObject {
    
    private var centralManager: CBCentralManager
    private var timeoutTimer: NSTimer?
    
    private var isScan: Bool = true
    private var scanClosure: (([DeviceManagerProtocol]) -> Void)?
    
    private var scanDevice: [DeviceManagerProtocol] = []
    private var scanDeviceType: [DeviceType]?
    
    private var currentDevice: DeviceManagerProtocol?
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanDevice(scanTypes: [DeviceType]? ,complete: ([DeviceManagerProtocol]) -> Void) {
        isScan = true
        scanDevice.removeAll()
        scanClosure = complete
        scanDeviceType = scanTypes
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("scanTimeout"), userInfo: nil, repeats: false)
    }
    
    func connect(peripheral: CBPeripheral) {
//        centralManager.delegate = self
//        centralManager.connectPeripheral(self.peripheral!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
    }
    
    func fire(uuid: String, info: [String : AnyObject], complete: (ResultProtocol?, NSError?) -> Void) {
        
        if currentDevice != nil && currentDevice?.uuid == uuid {
            currentDevice?.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: NSError?) -> Void in
                    self.currentDevice = nil
                    complete(result, error)
                })
        }
        else {
            scanDevice(nil, complete: { [unowned self] (results: [DeviceManagerProtocol]) -> Void in
                for device in results {
                    if device.uuid == uuid {
                        self.currentDevice = device
                        self.currentDevice?.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: NSError?) -> Void in
                            self.currentDevice = nil
                            complete(result, error)
                        })
                    }
                }
            })
        }
    }
    
    func clearWork() {
        self.centralManager.stopScan()
        if currentDevice?.peripheral != nil {
            self.centralManager.cancelPeripheralConnection(currentDevice!.peripheral!)
        }
        currentDevice?.peripheral = nil
        currentDevice?.characteristic = nil
        timeoutTimer?.invalidate()
        scanClosure = nil
        scanDeviceType = nil
        currentDevice = nil
    }
    
    func scanTimeout() {
        
        if isScan {
            scanClosure?(scanDevice)
        }
        clearWork()
//        syncComplete?([], NSError(domain: "超时", code: 0, userInfo: [NSLocalizedDescriptionKey : "搜索设备超时"]))
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("CentralManager is initialized")
        switch central.state {
        case CBCentralManagerState.Unauthorized:
            print("The app is not authorized to use Bluetooth low energy.")
        case CBCentralManagerState.PoweredOff:
            print("Bluetooth is currently powered off.")
        case CBCentralManagerState.PoweredOn:
            print("Bluetooth is currently powered on and available to use.")
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        default:
            break
            
        }
    }
    
    func isMyDevice(var scanTypes: [DeviceType]?, data: NSData) -> Bool {
        
        if scanTypes == nil {
            scanTypes = [DeviceType.MyBody, .Bracelet, .MyBodyMini, .MyBodyPlus]
        }
        
        for type in scanTypes! {
            if type.AdvDataManufacturerData.rangeOfData(type.AdvDataManufacturerData, options: NSDataSearchOptions.Backwards, range: NSRange(location: 0, length: type.AdvDataManufacturerData.length)).location != NSNotFound {
                return true
            }
        }
        
        return false
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("--------------------------------- %s",__FUNCTION__)
        
        print("CenCentalManagerDelegate didDiscoverPeripheral")
        print("Discovered \(peripheral)")
        print("Rssi: \(RSSI)")
        print("advertisementData: \(advertisementData)")
        
        //        kCBAdvDataManufacturerData.con
        let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? NSData
        let kCBAdvDataIsConnectable = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber
        
        if kCBAdvDataManufacturerData == nil || kCBAdvDataIsConnectable == nil {
            return
        }
        
        if isScan {
            if isMyDevice(scanDeviceType, data: kCBAdvDataManufacturerData!) && kCBAdvDataIsConnectable == 1 {
                
                // (DeviceType, name: String, UUID: String, peripheral: CBPeripheral)
//                scanDevice.append(())
                
//                if braceletUUID == nil || (braceletUUID != nil && braceletUUID == peripheral.identifier.UUIDString) {
//                    DBManager.shareInstance().addDevice(peripheral.identifier.UUIDString, name: peripheral.name!, type: DeviceType.Bracelet)
//                    
//                    self.peripheral = peripheral
//                    
//                    
//                    connect(self.peripheral!)
//                    print("Stop scan the Ble Devices")
//                }
                
            }
        }
        else {
            if isMyDevice(scanDeviceType, data: kCBAdvDataManufacturerData!) && kCBAdvDataIsConnectable == 1 {
                
//                if braceletUUID == nil || (braceletUUID != nil && braceletUUID == peripheral.identifier.UUIDString) {
//                    DBManager.shareInstance().addDevice(peripheral.identifier.UUIDString, name: peripheral.name!, type: DeviceType.Bracelet)
//                    
//                    self.peripheral = peripheral
//                    connect(self.peripheral!)
//                    centralManager.stopScan()
//                    timeoutTimer?.invalidate()
//                    print("Stop scan the Ble Devices")
//                }
                
            }
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // 连接上 外设  开始查找服务
        NSLog("Did connect to peripheral: %@", peripheral);
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("connect peripheral error: %@", error!)
//        syncComplete?([], error)
        clearWork()
    }
}

// 外设手环服务
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error == nil && self.peripheral!.services != nil {
            
            for service: CBService in self.peripheral!.services! {
                if service.UUID == CBUUID(string: "FFF0") {
                    self.peripheral!.discoverCharacteristics(nil, forService: service)
                    break
                }
            }
        }
        else {
            // 调用失败代理
            clearWork()
//            syncComplete?([], error)
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error == nil && service.characteristics != nil {
            for characteristic in service.characteristics! {
                if characteristic.UUID == CBUUID(string: "FFF1") || characteristic.UUID == CBUUID(string: "FFF2") {
                    
                    self.characteristic = characteristic
                    self.peripheral?.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
        else {
            // 调用失败代理
            NSLog("didDiscoverCharacteristicsForService error %@", error!)
            clearWork()
//            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        
        
        if error == nil && characteristic.value != nil {
            print("接收到数据: \(characteristic.value)")
//            decodeData(characteristic.value!)
        }
        else {
            // 调用失败代理
            NSLog("didUpdateValueForCharacteristic error %@", error!)
            clearWork()
//            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            NSLog("didWriteValueForCharacteristic %@", error!)
            // 调用失败代理
            clearWork()
//            syncComplete?([], error)
        }
    }
}