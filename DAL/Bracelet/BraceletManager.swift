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
    
    private var timeoutTimer: NSTimer?
    private var results: [BraceletResult] = []  // 同步运动数据
    var device_model: Int = 0 // 设备类型
    var firm_ver: UInt16 = 0 // 固件版本号
    var percent: UInt8 = 0  // 电池电量
    
    private var syncDate: NSDate?
    private var syncComplete: (([BraceletResult], NSError?) -> Void)?
    private var braceletUUID: String?
    
    private var AdvDataManufacturerData: NSData {
        // a8 01 01 01 08 f4 06 a5 00 be 3f
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
    }
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        timeoutTimer?.invalidate()
    }
    
    func connect(peripheral: CBPeripheral) {
        centralManager.delegate = self
        centralManager.connectPeripheral(self.peripheral!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
    }
    
    func clearWork() {
        self.centralManager.stopScan()
        if peripheral != nil {
            self.centralManager.cancelPeripheralConnection(self.peripheral!)
        }
        self.peripheral = nil
        self.characteristic = nil
        timeoutTimer?.invalidate()
        receiveData.setData(NSData())
    }
    
    func scanTimeout() {
        clearWork()
        syncComplete?([], NSError(domain: "超时", code: 0, userInfo: [NSLocalizedDescriptionKey : "搜索设备超时"]))
    }
}

extension BraceletManager: BraceletProtocol {
    func syncData(date: NSDate, deviceUUID: String?, syncComplete: (([BraceletResult], NSError?) -> Void)) {
        syncDate = date
        braceletUUID = deviceUUID
        results.removeAll(keepCapacity: true)
        self.syncComplete = syncComplete
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("scanTimeout"), userInfo: nil, repeats: false)
    }
}

extension BraceletManager: CBCentralManagerDelegate {
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
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("--------------------------------- %s",__FUNCTION__)
        
        print("CenCentalManagerDelegate didDiscoverPeripheral")
        print("Discovered \(peripheral)")
        print("Rssi: \(RSSI)")
        print("advertisementData: \(advertisementData)")
        
        let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? NSData
        let kCBAdvDataIsConnectable = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber
        if kCBAdvDataManufacturerData == AdvDataManufacturerData && kCBAdvDataIsConnectable == 1 {
            
            if braceletUUID == nil || (braceletUUID != nil && braceletUUID == peripheral.identifier.UUIDString) {
                DBManager.shareInstance().addDevice(peripheral.identifier.UUIDString, name: peripheral.name!, type: 1)
                
                self.peripheral = peripheral
                connect(self.peripheral!)
                centralManager.stopScan()
                timeoutTimer?.invalidate()
                print("Stop scan the Ble Devices")
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
        syncComplete?([], error)
        clearWork()
    }
}

// 外设手环服务
extension BraceletManager: CBPeripheralDelegate {
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
            syncComplete?([], error)
            
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
            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        
        
        if error == nil && characteristic.value != nil {
            print("接收到数据: \(characteristic.value)")
            decodeData(characteristic.value!)
        }
        else {
            // 调用失败代理
            NSLog("didUpdateValueForCharacteristic error %@", error!)
            clearWork()
            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            NSLog("didWriteValueForCharacteristic %@", error!)
            // 调用失败代理
            clearWork()
            syncComplete?([], error)
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
                    
                    results.removeAll()
                    // 时间请求包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    receiveData.setData(NSData())
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
                    // 收到运动数据
                    print("\(currentFormate)")
                    
                    results += dealSuccessData()
                    
                    // 发送运动反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.sportCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    
                    receiveData.setData(NSData())
                    
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.generalCmdId {
                    //收到设备信息
                    if let bodyPackage = currentFormate?.packageBody as? BraceletDeviceVersionReqPackageBody {
                        firm_ver = bodyPackage.firm_ver
                        device_model = bodyPackage.device_model
                    }
                    
                    // 发送通用反馈包
                    let formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.generalCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
                    
                    receiveData.setData(NSData())
                }
                else if currentFormate?.packageBody?.cmd_type == BraceletBlueToothFormats.batteryCmdId {
                    // 收到电量数据 可以结束了
                    if let p = (currentFormate?.packageBody as? BraceletBatteryReqPackageBody)?.percent {
                        percent = p
                    }
                    
                    syncComplete?(results, nil)
                    clearWork()
                    results.removeAll()
                }
            }
        }
    }
    
    func dealSuccessData() -> [BraceletResult] {
        var list: [BraceletResult] = []
        
        if let bodyData = currentFormate?.packageBody as? BraceletSportReqPackageBody {
            var startTime = bodyData.start_time
            
            for data in bodyData.info {
                let result = BraceletResult(userId: UInt16(UserData.shareInstance().userId!), startTime: startTime, endTime: data.end_time, steps: data.steps, stepsType: data.stepsType)
                list.append(result)
                startTime = data.end_time
            }
        }
        
        return list
    }
}
