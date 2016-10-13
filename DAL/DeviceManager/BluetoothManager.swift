//
//  BluetoothManager.swift
//  Health
//
//  Created by Yalin on 15/10/7.
//  Copyright © 2015年 Yalin. All rights reserved.
// cstf158tfht0123456789

import UIKit
import CoreBluetooth

enum DeviceType: Int16 {
    case myBody = 0
    case bracelet
    case myBodyMini
    case myBodyPlus
    
    var AdvDataManufacturerData: Data {
        
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
        let mybodyNewData = Data(bytes: UnsafePointer<UInt8>(mybodyNewBuffer), count: mybodyNewBuffer.count)
        
        
        switch self {
        case .bracelet:
            // a8 01 01 01 08 f4 06 a5 00 be 3f
            // a8 01 01 01 08 f4 06 a5 00 be 3f 01 0108f406 a500be3f
            var buffer: [UInt8] = []
            buffer.append(0xf4)
            buffer.append(0x06)
            buffer.append(0xa5)
            
            let data = Data(bytes: UnsafePointer<UInt8>(buffer), count: buffer.count)
            return data
        case .myBody:
            return mybodyNewData
        case .myBodyMini:
            return mybodyNewData
        case .myBodyPlus:
            return mybodyNewData
//        default:
//            return NSData()
        }
    }
}

/*
 if status == CBCentralManagerState.poweredOff {
 self.tipLabel.text = "蓝牙未打开,请打开蓝牙!"
 }
 else if status == CBCentralManagerState.unauthorized {
 self.tipLabel.text = "蓝牙未被授权,请在设置中对此应用进行授权!"
 }
 else if status == CBCentralManagerState.unsupported {
 self.tipLabel.text = "设备不支持蓝牙,无法使用!"
 }
 else if status == CBCentralManagerState.poweredOn {
 self.tipLabel.text = "蓝牙已打开，请上秤后摇一摇手机，将秤放在坚硬平整的地面上，赤脚测量!"
 self.canScale = true
 }
 */
enum BluetoothStatus {
    case poweredOff
    case unauthorized
    case unsupported
    case poweredOn
}

class BluetoothManager: NSObject {
    
    fileprivate var centralManager: CBCentralManager
    fileprivate var timeoutTimer: Timer?
    
    fileprivate var isScan: Bool = true
    fileprivate var scanClosure: (([DeviceManagerProtocol],Bool, NSError?) -> Void)?
//    private var fileClosure: ((ResultProtocol?, isTimeOut: Bool, NSError?) -> Void)?
    
    fileprivate var scanDevice = NSMutableDictionary()
    fileprivate var scanDeviceType: [DeviceType]?
    
    fileprivate var currentDevice: DeviceManagerProtocol?
    fileprivate var currentFireInfo: [String : AnyObject]?
    
    
    static let shareInstance = BluetoothManager()
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanDevice(_ scanTypes: [DeviceType]? ,complete: @escaping ([DeviceManagerProtocol], _ isTimeOut: Bool, NSError?) -> Void) {
        isScan = true
        scanDevice.removeAllObjects()
        scanClosure = complete
        scanDeviceType = scanTypes
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        centralManager.delegate = self;
        
//        timeoutTimer = NSTimer(timeInterval: 30, target: self, selector: Selector("scanTimerFinished"), userInfo: nil, repeats: false)
//        timeoutTimer?.fire()
        if timeoutTimer != nil {
            if timeoutTimer!.isValid {
                timeoutTimer?.invalidate()
            }
            timeoutTimer = nil
        }
        
        timeoutTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(BluetoothManager.scanTimerFinished(_:)), userInfo: nil, repeats: false)
    }
    
    func scanTimerFinished(_ timer: Timer) {
        if timeoutTimer != nil {
            
            timeoutTimer?.invalidate()
            var devices: [DeviceManagerProtocol] = []
            for value in scanDevice.allValues {
                devices.append(value as! DeviceManagerProtocol)
            }
            scanClosure?(devices, true, NSError(domain: "搜索结束", code: 1001, userInfo: [NSLocalizedDescriptionKey : "搜索时间到"]))
            
            clearWork()
        }
    }
    
    func stopScanDevice() {
        clearWork()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        
        if currentDevice?.type == DeviceType.myBody {
            self.clearWork()
        }
        else {
            centralManager.delegate = self
            centralManager.connect(currentDevice!.peripheral!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(value: true as Bool)])
        }
    }
    
    func fire(_ uuid: String, info: [String : Any], complete: @escaping (ResultProtocol?, _ isTimeOut: Bool, NSError?) -> Void) {
        
//        fileClosure = complete
        
        if currentDevice != nil && currentDevice?.uuid == uuid {
            self.isScan = false
            connect(currentDevice!.peripheral!)
            currentDevice?.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: Error?) -> Void in
                    self.currentDevice = nil
                    complete(result, false, error as NSError?)
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
                            currentDevice.fire(info, complete: { [unowned self] (result: ResultProtocol?, error: Error?) -> Void in
                                
                                complete(result,isTimeOut, error as NSError?)
                                self.clearWork()
                                self.currentDevice = nil
                            })
                            
                            self.timeoutTimer?.invalidate()
                        }
                    }
                }
                else
                {
                    complete(nil,isTimeOut, error)
                }
            })
        }
    }
    
    func clearWork() {
        
        NSLog("clear work =============================");
        
        
        if currentDevice?.peripheral != nil {
            NSLog("\(self.centralManager)xxxxxxxxxxxxxxxxxxxxxxxxx\(currentDevice!.peripheral!)");
            self.centralManager.cancelPeripheralConnection(currentDevice!.peripheral!)
        }
        self.centralManager.stopScan()
        self.centralManager.delegate = nil
        currentDevice?.peripheral?.delegate = nil
        currentDevice?.peripheral = nil
        currentDevice?.characteristic = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        scanClosure = nil
//        fileClosure = nil
        scanDeviceType = nil
        currentDevice = nil
    }
    
    fileprivate var statusBlock: ((BluetoothStatus) -> Void)?
    fileprivate var status: BluetoothStatus = .unsupported
    
    func setCheckStatusBlock(_ complete: @escaping (BluetoothStatus) -> Void) {
        statusBlock = complete
        
        if status == .unsupported {
            centralManager.scanForPeripherals(withServices: nil, options: nil);
        }
        else {
            statusBlock?(status)
        }
        
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var status = BluetoothStatus.unsupported
        
        if #available(iOS 10.0, *) {
            switch central.state{
            case CBManagerState.unauthorized:
                print("This app is not authorised to use Bluetooth low energy")
                status = .unauthorized
            case CBManagerState.poweredOff:
                print("Bluetooth is currently powered off.")
                status = .poweredOff
            case CBManagerState.poweredOn:
                print("Bluetooth is currently powered on and available to use.")
                status = .poweredOn
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            default:break
            }
        } else {
            // Fallback on earlier versions
            switch central.state.rawValue {
            case 3: // CBCentralManagerState.unauthorized :
                print("This app is not authorised to use Bluetooth low energy")
                status = .unauthorized
            case 4: // CBCentralManagerState.poweredOff:
                print("Bluetooth is currently powered off.")
                status = .poweredOff
            case 5: //CBCentralManagerState.poweredOn:
                print("Bluetooth is currently powered on and available to use.")
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                status = .poweredOn
            default:break
            }
        }
        
        self.status = status
        statusBlock?(status)
    }
    
    func isScanMyDevice(_ scanTypes: inout [DeviceType]?, peripheral: CBPeripheral, advertisementData: [String : AnyObject]) -> DeviceManagerProtocol? {
        
        let kCBAdvDataIsConnectable = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber
        
        if kCBAdvDataIsConnectable != 1 {
            return nil
        }
        
        if scanTypes == nil {
            scanTypes = [DeviceType.myBody, .bracelet, .myBodyMini, .myBodyPlus]
        }
        
        // 判断是否是手环
        if scanTypes!.contains(DeviceType.bracelet) {
            if let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                
                let macData = kCBAdvDataManufacturerData.subdata(in: kCBAdvDataManufacturerData.count - 6..<kCBAdvDataManufacturerData.count - 3)
//                let macData = kCBAdvDataManufacturerData.subdata(with: NSRange(location: kCBAdvDataManufacturerData.count - 6, length: 3))
                
                if macData == DeviceType.bracelet.AdvDataManufacturerData {
                    return BraceletManager(name: peripheral.name == nil ? "手环" : peripheral.name!, uuid: peripheral.identifier.uuidString, peripheral: peripheral, characteristic: nil)
                }
            }
        }
        
        // 判断是否是 老秤
        if scanTypes!.contains(DeviceType.myBody) {
            if peripheral.name == "VScale" {
                return MyBodyManager(name: peripheral.name!, uuid: peripheral.identifier.uuidString, peripheral: peripheral, characteristic: nil)
            }
        }
        
        // 判断是否是 新秤
        if scanTypes!.contains(DeviceType.myBodyMini) || scanTypes!.contains(DeviceType.myBodyPlus) {
            if peripheral.name == "BodyMini" || peripheral.name == "BodyPlus" {
                return MyBodyMiniAndPlusManager(name: peripheral.name!, uuid: peripheral.identifier.uuidString, peripheral: peripheral, characteristic: nil)
            }
        }
        
        return nil
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("--------------------------------- %s",#function)
        
        print("CenCentalManagerDelegate didDiscoverPeripheral")
        print("Discovered \(peripheral)")
        print("Rssi: \(RSSI)")
        print("advertisementData: \(advertisementData)")
        
        if let device = isScanMyDevice(&scanDeviceType, peripheral: peripheral, advertisementData: advertisementData as [String : AnyObject]) {
            
            device.RSSI = RSSI
            scanDevice.setObject(device, forKey: device.uuid as NSCopying)
            
            var devices: [DeviceManagerProtocol] = []
            for value in scanDevice.allValues {
                devices.append(value as! DeviceManagerProtocol)
            }
            scanClosure?(devices, false, nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 连接上 外设  开始查找服务
        NSLog("Did connect to peripheral: %@", peripheral);
        currentDevice?.peripheral?.delegate = self
        currentDevice?.peripheral?.discoverServices(nil)
        currentDevice?.centralManager?(central, didConnect: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("connect peripheral error: \(error!)")
//        syncComplete?([], error)
        currentDevice?.centralManager?(central, didFailToConnect: peripheral, error: error)
        // ResultProtocol?, isTimeOut: Bool, NSError?
//        fileClosure?(nil, isTimeOut: false, error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral error: \(error)")
//        scanClosure?(devices, false, nil)
        currentDevice?.centralManager?(central, didDisconnectPeripheral: peripheral, error: error)
    }
}

// 外设服务
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil && currentDevice?.peripheral?.services != nil {
            for service: CBService in currentDevice!.peripheral!.services! {
                if service.uuid == CBUUID(string: currentDevice!.serviceUUID) {
                    currentDevice?.peripheral!.discoverCharacteristics(nil, for: service)
                    break
                }
            }
        }
        else {
            currentDevice?.peripheral?(peripheral, didDiscoverServices: error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        currentDevice?.peripheral?(peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        currentDevice?.peripheral?(peripheral, didUpdateValueFor: characteristic, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        currentDevice?.peripheral?(peripheral, didWriteValueFor: characteristic, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        currentDevice?.peripheral?(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
    }
}
