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
    private var results: [BraceletResult] = []
    
    private var syncDate: NSDate?
    private var syncComplete: (([BraceletResult], NSError?) -> Void)?
    
    let braceletUUID = "B8199D74-6460-C7D2-E7F3-63D97C435365"
    
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
        centralManager.connectPeripheral(self.peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true)])
    }
    
    func clearWork() {
        self.centralManager.stopScan()
        if peripheral != nil {
            self.centralManager.cancelPeripheralConnection(self.peripheral!)
        }
        self.peripheral = nil
        self.characteristic = nil
        timeoutTimer?.invalidate()
    }
    
    func scanTimeout() {
        clearWork()
        syncComplete?([], NSError(domain: "超时", code: 0, userInfo: [NSLocalizedDescriptionKey : "搜索设备超时"]))
    }
}

extension BraceletManager: BraceletProtocol {
    func syncData(date: NSDate, syncComplete: (([BraceletResult], NSError?) -> Void)) {
        syncDate = date
        results.removeAll(keepCapacity: true)
        self.syncComplete = syncComplete
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("scanTimeout"), userInfo: nil, repeats: false)
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
        
        if peripheral.identifier == NSUUID(UUIDString: braceletUUID) {
            
            DBManager.shareInstance().addDevice(peripheral.identifier.UUIDString, name: peripheral.name, type: 1)
            
            self.peripheral = peripheral
            connect(self.peripheral!)
            centralManager.stopScan()
            timeoutTimer?.invalidate()
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
        syncComplete?([], error)
        clearWork()
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
            clearWork()
            syncComplete?([], error)
            
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
            clearWork()
            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("接收到数据: \(characteristic.value)")
        
        if error == nil {
            decodeData(characteristic.value)
        }
        else {
            // 调用失败代理
            clearWork()
            syncComplete?([], error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            NSLog("%@", error)
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
                    // 时间请求包
                    var formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.responseTimeCmdId, time: NSDate())
                    self.peripheral!.writeValue(formats.toData(), forCharacteristic: self.characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                else if currentFormate!.packageBody?.cmd_type == BraceletBlueToothFormats.sportCmdId {
                    // 收到运动数据 可以结束了?
                    println("\(currentFormate)")
                    
                    results += dealSuccessData()
                    
                    // 发送运动反馈包
                    var formats = BraceletBlueToothFormats(cmdId: BraceletBlueToothFormats.sportCmdId, time: NSDate())
                    
//                    syncComplete?(dealSuccessData(), nil)
//                    
//                    clearWork()
                }
                else if currentFormate!.packageBody?.cmd_type == 13 {
                    
                }
            }
        }
    }
    
    func dealSuccessData() -> [BraceletResult] {
        var list: [BraceletResult] = []
        
        if let bodyData = currentFormate?.packageBody as? BraceletSportReqPackageBody {
            var startTime = bodyData.start_time
            
            for data in bodyData.info {
                var result = BraceletResult(userId: UInt16(UserData.shareInstance().userId!), startTime: startTime, endTime: data.end_time, steps: data.steps, stepsType: data.stepsType)
                list.append(result)
                startTime = data.end_time
            }
        }
        
        return list
    }
}
