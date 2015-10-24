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
//        default:
//            return NSData()
        }
    }
}

class BluetoothManager: NSObject {
    
    private var centralManager: CBCentralManager
    private var timeoutTimer: NSTimer?
    
    private var isScan: Bool = true
    private var scanClosure: (([DeviceManagerProtocol],Bool, NSError?) -> Void)?
    
    private var scanDevice = NSMutableDictionary()
    private var scanDeviceType: [DeviceType]?
    
    private var currentDevice: DeviceManagerProtocol?
    private var currentFireInfo: [String : AnyObject]?
    
    
    static let shareInstance = BluetoothManager()
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanDevice(scanTypes: [DeviceType]? ,complete: ([DeviceManagerProtocol], isTimeOut: Bool, NSError?) -> Void) {
        isScan = true
        scanDevice.removeAllObjects()
        scanClosure = complete
        scanDeviceType = scanTypes
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
        centralManager.delegate = self;
        
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("scanTimerFinished"), userInfo: nil, repeats: false)
    }
    
    func scanTimerFinished() {
        timeoutTimer?.invalidate()
        var devices: [DeviceManagerProtocol] = []
        for value in scanDevice.allValues {
            devices.append(value as! DeviceManagerProtocol)
        }
        scanClosure?(devices, true, NSError(domain: "搜索结束", code: 1001, userInfo: [NSLocalizedDescriptionKey : "搜索时间到"]))
        
        clearWork()
    }
    
    func stopScanDevice() {
        clearWork()
    }
    
    func connect(peripheral: CBPeripheral) {
        
        if currentDevice?.type == DeviceType.MyBody {
            self.clearWork()
        }
        else {
            centralManager.delegate = self
            centralManager.connectPeripheral(currentDevice!.peripheral!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
        }
    }
    
    func fire(uuid: String, info: [String : Any], complete: (ResultProtocol?, isTimeOut: Bool, NSError?) -> Void) {
        
        if currentDevice != nil && currentDevice?.uuid == uuid {
            self.isScan = false
            connect(currentDevice!.peripheral!)
            currentDevice?.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: NSError?) -> Void in
                    self.currentDevice = nil
                    complete(result, isTimeOut: false, error)
                    self.clearWork()
                })
        }
        else {
            scanDevice(nil, complete: { [unowned self] (results: [DeviceManagerProtocol], isTimeOut: Bool, error: NSError?) -> Void in
                
                if error == nil {
                    for device in results {
                        if device.uuid == uuid {
                            self.centralManager.stopScan()
                            self.currentDevice = device
                            self.isScan = false
                            
                            let currentDevice = self.currentDevice!
                            self.connect(self.currentDevice!.peripheral!)
                            currentDevice.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: NSError?) -> Void in
                                
                                complete(result,isTimeOut: isTimeOut, error)
                                self.clearWork()
                                self.currentDevice = nil
                            })
                        }
                    }
                }
                else
                {
                    complete(nil,isTimeOut: isTimeOut, error)
                }
            })
        }
    }
    
    func clearWork() {
        self.centralManager.stopScan()
        if currentDevice?.peripheral != nil {
            self.centralManager.cancelPeripheralConnection(currentDevice!.peripheral!)
        }
        self.centralManager.delegate = nil
        currentDevice?.peripheral?.delegate = nil
        currentDevice?.peripheral = nil
        currentDevice?.characteristic = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        scanClosure = nil
        scanDeviceType = nil
        currentDevice = nil
    }
    
    private var statusBlock: ((CBCentralManagerState) -> Void)?
    func setCheckStatusBlock(complete: (CBCentralManagerState) -> Void) {
        statusBlock = complete
        
        if centralManager.state == CBCentralManagerState.Unknown {
            centralManager.scanForPeripheralsWithServices(nil, options: nil);
        }
        else {
            statusBlock?(centralManager.state)
        }
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
        
        statusBlock?(centralManager.state)
    }
    
    func isScanMyDevice(var scanTypes: [DeviceType]?, peripheral: CBPeripheral, advertisementData: [String : AnyObject]) -> DeviceManagerProtocol? {
        
        let kCBAdvDataIsConnectable = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber
        
        if kCBAdvDataIsConnectable != 1 {
            return nil
        }
        
        if scanTypes == nil {
            scanTypes = [DeviceType.MyBody, .Bracelet, .MyBodyMini, .MyBodyPlus]
        }
        
        // 判断是否是手环
        if scanTypes!.contains(DeviceType.Bracelet) {
            if let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? NSData {
                if kCBAdvDataManufacturerData.rangeOfData(DeviceType.Bracelet.AdvDataManufacturerData, options: NSDataSearchOptions.Backwards, range: NSRange(location: 0, length: kCBAdvDataManufacturerData.length)).location != NSNotFound {
                    return BraceletManager(name: peripheral.name == nil ? "手环" : peripheral.name!, uuid: peripheral.identifier.UUIDString, peripheral: peripheral, characteristic: nil)
                }
            }
        }
        
        // 判断是否是 老秤
        if scanTypes!.contains(DeviceType.MyBody) {
            if peripheral.name == "VScale" {
                return MyBodyManager(name: peripheral.name!, uuid: peripheral.identifier.UUIDString, peripheral: peripheral, characteristic: nil)
            }
        }
        
        // 判断是否是 新秤
        if scanTypes!.contains(DeviceType.MyBodyMini) || scanTypes!.contains(DeviceType.MyBodyPlus) {
            if peripheral.name == "BodyMini" || peripheral.name == "BodyPlus" {
                return MyBodyMiniAndPlusManager(name: peripheral.name!, uuid: peripheral.identifier.UUIDString, peripheral: peripheral, characteristic: nil)
            }
        }
        
        return nil
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("--------------------------------- %s",__FUNCTION__)
        
        print("CenCentalManagerDelegate didDiscoverPeripheral")
        print("Discovered \(peripheral)")
        print("Rssi: \(RSSI)")
        print("advertisementData: \(advertisementData)")
        
        if let device = isScanMyDevice(scanDeviceType, peripheral: peripheral, advertisementData: advertisementData) {
            
            device.RSSI = RSSI
            scanDevice.setObject(device, forKey: device.uuid)
            
            var devices: [DeviceManagerProtocol] = []
            for value in scanDevice.allValues {
                devices.append(value as! DeviceManagerProtocol)
            }
            scanClosure?(devices, false, nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        // 连接上 外设  开始查找服务
        NSLog("Did connect to peripheral: %@", peripheral);
        currentDevice?.peripheral?.delegate = self
        currentDevice?.peripheral?.discoverServices(nil)
        currentDevice?.centralManager?(central, didConnectPeripheral: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("connect peripheral error: %@", error!)
//        syncComplete?([], error)
        currentDevice?.centralManager?(central, didFailToConnectPeripheral: peripheral, error: error)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral error: \(error)")
    }
}

// 外设服务
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error == nil && currentDevice?.peripheral?.services != nil {
            for service: CBService in currentDevice!.peripheral!.services! {
                if service.UUID == CBUUID(string: currentDevice!.serviceUUID) {
                    currentDevice?.peripheral!.discoverCharacteristics(nil, forService: service)
                    break
                }
            }
        }
        else {
            currentDevice?.peripheral?(peripheral, didDiscoverServices: error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        currentDevice?.peripheral?(peripheral, didDiscoverCharacteristicsForService: service, error: error)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        currentDevice?.peripheral?(peripheral, didUpdateValueForCharacteristic: characteristic, error: error)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        currentDevice?.peripheral?(peripheral, didWriteValueForCharacteristic: characteristic, error: error)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        currentDevice?.peripheral?(peripheral, didUpdateNotificationStateForCharacteristic: characteristic, error: error)
    }
}