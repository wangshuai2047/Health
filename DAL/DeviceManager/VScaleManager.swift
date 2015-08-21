//
//  VScaleManager.swift
//  Health
//
//  Created by Yalin on 15/8/16.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import AudioToolbox

let KEY_MODEL_NUMBER = "modelNumber"

protocol VScaleManagerDelegate {
    func updateDeviceStatus(status: VScaleManager.VCStatus)
    func updateUIData(result: VTFatScaleTestResult)
}

class VScaleManager: NSObject{
   
    enum VCStatus {
        case Disconnected
        case Discovered
        case Connecting
        case Connected
        case ServiceReady
        case Caculate
        case Holding
    }
    
    var curStatus: VCStatus = .Disconnected
    var scaleResult: VTFatScaleTestResult?
    var delegate: VScaleManagerDelegate?
    
    private var deviceManager: VTDeviceManager?
    private var deviceModel: VTDeviceModel?
    private var serviceUUID: [CBUUID] = []
    
    static func shareInstance() -> VScaleManager {
        struct Singleton {
            static var predicate: dispatch_once_t = 0
            static var instance: VScaleManager? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            Singleton.instance = VScaleManager()
        })
        
        return Singleton.instance!
    }
    
    override init() {
        scaleResult = VTFatScaleTestResult()
        deviceManager = VTDeviceManager.sharedInstance()
        serviceUUID = [CBUUID(string: "0X1800"),CBUUID(string: "0X1801"),CBUUID(string: "0X1802"),CBUUID(string: BLE_SCALE_SERVICE_UUID)]
        
        super.init()
        
        deviceManager?.delegate = self
        
        NSLog("[VScaleManager] init scanning")
    }
    
    func scan() {
        deviceManager?.scan(serviceUUID)
    }
    
    func disconnect() {
        println("disconnect status = \(curStatus)")
        
        if curStatus != VCStatus.Disconnected && curStatus != VCStatus.Discovered {
            
            if let modelNumber = deviceModel?.getMetaData(KEY_MODEL_NUMBER, defaultValue: nil) as? NSNumber {
//                let modelNumberInt = modelNumber.integerValue
//                let value2 = 0x0103
//                let value3 = 0xFFFF0000
//                let value = (modelNumberInt & value3) >> 16
//                if value == value2 {
//                    deviceModel?.profile.suspendDevice(deviceModel)
//                }// integer literal overflows when stored into 'Int'
//                else {
//                    deviceModel?.disconnect()
//                }
            }
            else {
                deviceModel?.disconnect()
            }
        }
    }
    
    private func gotoStatus(status: VCStatus) {
        curStatus = status
        delegate?.updateDeviceStatus(status)
    }
    
    private func scheduleNotificationOn(
        fireDate: NSDate?,
        alertText: String?,
        alertAction: String?,
        soundfileName: String?,
        launchImage: String?,
        userInfo: [String:AnyObject]?,
        counted: Bool,
        repeat: NSCalendarUnit,
        enable: Bool) -> UILocalNotification? {
        
            if !enable {
                if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                    return nil
                }
            }
            
            var localNotification = UILocalNotification()
            localNotification.fireDate = fireDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            localNotification.alertBody = alertText
            localNotification.alertAction = alertAction
            
            if repeat != NSCalendarUnit.CalendarUnitEra {
                localNotification.repeatInterval = repeat
            }
            
            localNotification.soundName = soundfileName
            
            localNotification.alertLaunchImage = launchImage
            localNotification.applicationIconBadgeNumber = 1
            localNotification.userInfo = userInfo
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            return localNotification
    }
}

extension VScaleManager: VTDeviceDelegate, VTProfileScaleDelegate {
    func didTestResultValueUpdate(device: VTDeviceModel!, scaleType: UInt8, result: AnyObject!) {
        NSLog("didTestResultValueUpdate")
        
        if result != nil {
            switch scaleType {
            case UInt8(VT_VSCALE_FAT):
                scaleResult = result as? VTFatScaleTestResult
                if scaleResult?.weight == 0.0 {
                    return
                }
                
                switch curStatus {
                case .ServiceReady:
                    gotoStatus(VCStatus.Holding)
                    NSLog("VC_STATUS_SERVICE_READY done")
                    delegate?.updateUIData(scaleResult!)
                    
                    var _currentUser = VTScaleUser()
                    _currentUser.userID = 0x9
                    _currentUser.gender = 0
                    _currentUser.age = 27
                    _currentUser.height = 178
                    deviceModel?.profile.caculateResult(deviceModel, user: _currentUser)
                    gotoStatus(VCStatus.Caculate)
                    
                case .Caculate:
                    NSLog("VC_STATUS_CACULATING done")
                    gotoStatus(VCStatus.Caculate)
                    delegate?.updateUIData(scaleResult!)
                    gotoStatus(VCStatus.ServiceReady)
                    
                case .Holding:
                    NSLog("VC_STATUS_HOLDING done")
                    gotoStatus(VCStatus.Holding)
                    // ignored
                default:
                    break
                }
            default:
                break
            }
        }
    }
}

extension VScaleManager: VTDeviceManagerDelegate, VTProfileDeviceDelegate {
    func didDiscovered(dm: VTDeviceManager!, device: VTDeviceModel!) -> Boolean {
        NSLog("didDiscovered")
        
        return Boolean(0)
    }
    
    func didConnected(dm: VTDeviceManager!, device: VTDeviceModel!) {
        NSLog("didConnected")
        deviceModel = device
    }
    
    func didStatusUpdate(status: CBCentralManagerState) {
        NSLog("didStatusUpdate \(status)")
    }
    
    func didDisconnected(dm: VTDeviceManager!, device: VTDeviceModel!) {
        NSLog("didDisconnected")
        gotoStatus(VCStatus.Disconnected)
        deviceModel = nil
        
        AudioServicesPlaySystemSound(1003)
        
        gotoStatus(VCStatus.ServiceReady)
    }
    
    func didPaired(dm: VTDeviceManager!, device: VTDeviceModel!) {
        NSLog("didPaired")
    }
    
    func didAdvertised(dm: VTDeviceManager!, device: VTDeviceModel!) {
        NSLog("didAdvertised")
    }
    
    func didDataPushed(dm: VTDeviceManager!, device: VTDeviceModel!, advertise: VTAdvertise!) {
        NSLog("didDataPushed ManufactureId = \(advertise.manufactureId) type = \(advertise.type) data = \(advertise.data)")
        
        if curStatus == VCStatus.Disconnected {
            #if !(arch(i386) || arch(x86_64)) && os(iOS)
            let modelNumber = VTDeviceModelNumber(manufactureData: advertise.data)
                if modelNumber.version == UInt8(VT_DEVICE_MODEL_VERSION_1) && modelNumber.type == UInt8(VT_DEVICE_VSCALE) {
                    
                    // if found a new device
                    let vendorName = "vtrump"
                    let subType = "fat scale"
                    let msg = "Connect to \(vendorName) \(subType)?"
                    
                    let alertView = UIAlertView(title: "Scale Weight", message: msg, delegate: self, cancelButtonTitle: "cancel", otherButtonTitles:"ok")
                    device.delegate = self
                    
                    
                    deviceModel = device
                    gotoStatus(VCStatus.Discovered)
                    
                    AudioServicesPlaySystemSound(1002)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    scheduleNotificationOn(NSDate(), alertText: "Weight scale detected", alertAction: "View", soundfileName: nil, launchImage: device.imageUrl, userInfo: nil, counted: true, repeat: NSCalendarUnit.CalendarUnitEra, enable: false)
                    alertView.show()
                }
            #endif
        }
    }
    
    func didSerialNumberUpdated(device: VTDeviceModel!, serialNumber: AnyObject!) {
        if deviceModel?.UUID == device.UUID {
            if let data = serialNumber as? NSData {
                NSLog("serial Number is: \(data.description)")
            }
        }
    }
    
    func didFirmwareVersionUpdated(device: VTDeviceModel!, version: String!) {
        if deviceModel?.UUID == device.UUID {
            NSLog("firmware version is: \(version)")
        }
    }
    
    func didModelNumberUpdated(device: VTDeviceModel!, modelNumber: NSData!) {
        if deviceModel?.UUID == device.UUID {
//            let modelNumberArray: Byte = modelNumber.bytes as? Byte
//            let modelNumberInt = modelNumberArray[0] * 0x1000000 + modelNumberArray[1] * 0x10000 + modelNumberArray[2] * 0x100 + modelNumberArray[3]
//            let modelNumberValue = NSNumber(int: modelNumberInt)
//            
//            device.setMetaData(KEY_MODEL_NUMBER, value: modelNumberValue)
//            NSLog("modelNumber = 0x\(modelNumberInt)")
        }
    }
}

extension VScaleManager: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            if curStatus == VCStatus.Discovered {
                gotoStatus(VCStatus.Discovered)
            }
        case 1:
            deviceModel?.connect()
        default:
            break
        }
    }
}


























