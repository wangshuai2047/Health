//
//  DeviceManager.swift
//  Health
//
//  Created by Yalin on 15/8/16.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceManager: NSObject {
    
    var scaleHelper: ScaleProtocol = ScaleOld()
    var braceletManager: BraceletProtocol = BraceletManager()
    
    class func shareInstance() -> DeviceManager {
        struct Singleton {
            static var predicate: dispatch_once_t = 0
            static var instance: DeviceManager? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            Singleton.instance = DeviceManager()
        })
        
        return Singleton.instance!
    }
    
    override init() {
        super.init()
    }
    
    var isConnectDevice: Bool {
        
        
        return false
//        return scaleHelper != nil
    }
    
    func syncBraceletDatas(beginDate: NSDate, syncComplete: (([BraceletResult], NSError?) -> Void)) {
        braceletManager.syncData(beginDate, syncComplete: syncComplete)
    }
    
    func startScale(complete: (result: ScaleResult?, err: NSError?) -> Void) {
        scaleHelper.startScale(complete)
    }
    
    func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float) -> ScaleResult {
        return ScaleOld.scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent)
    }
}

//extension DeviceManager: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(central: CBCentralManager!) {
//        println("CentralManager is initialized")
//        switch central.state {
//        case CBCentralManagerState.Unauthorized:
//            println("The app is not authorized to use Bluetooth low energy.")
//        case CBCentralManagerState.PoweredOff:
//            println("Bluetooth is currently powered off.")
//        case CBCentralManagerState.PoweredOn:
//            println("Bluetooth is currently powered on and available to use.")
//        default:
//            break
//            
//        }
//    }
//    
//    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
//        
//        println("--------------------------------- %s",__FUNCTION__)
//        
//        println("CenCentalManagerDelegate didDiscoverPeripheral")
//        println("Discovered \(peripheral)")
//        println("Rssi: \(RSSI)")
//        println("advertisementData: \(advertisementData)")
//        
//        println("Stop scan the Ble Devices")
////        centralManager.stopScan()
//        //        cbPeripheral = peripheral
//    }
//}

/*
extension DeviceManager : VScaleManagerDelegate {
    
    // MARK: - Mybody Device Method
    var isDiscoverMyBodyDevice: Bool {
        return weightScaleOne.curStatus != VCStatus.Disconnected
    }
    
    func scanMyBodyDevice() {
        weightScaleOne.scan()
    }
    
    func connectMyBodyDevice() {
        
    }
    
    func startEvaluationWithMyBodyDevice() {
        
    }

    // MARK: VScaleManagerDelegate
    func updateDeviceStatus(status: VCStatus) {
        
        var result = ""
        switch status {
        case .Caculate:
            result = "caculate"
        case .Connected:
            result = "connected"
        case .Connecting:
            result = "connecting"
        case .Disconnected:
            result = "disconnected"
        case .Discovered:
            result = "discovered"
        case .Holding:
            result = "holding"
        case .ServiceReady:
            result = "serviceReady"
        }
        
        println("-----------------------\nupdateDeviceStatus: \(result)\n=======================")
    }
    
    func updateUIDataWithFatScale(result: VTFatScaleTestResult!) {
        let result = "-----------------------fat scale \n\nfound data:\n\n userId:\(result.userID) \n\nuser gender, 0 is male, 1 is female, 2 male athelete, 3 female athelete \ngender:\(result.gender) \n\nage:\(result.age) \n\nheight:\(result.height) \n\nfatContent:\(result.fatContent) \n\nwaterContent:\(result.waterContent) \n\nboneContent:\(result.boneContent) \n\nmuscleContent:\(result.muscleContent) \n\n visceralFatContent:\(result.visceralFatContent) \n\ncalorie:\(result.calorie) \n\nbmi:\(result.bmi)\n======================="
        
        println(result)
    }
    
    func updateUIDataWithWeightScale(result: VTScaleTestResult!) {
        let result = "-----------------------Weight scale \n\nfound dataType:\n\n userId:\(result.dataType) \n\nweight:\(result.weight)\n======================="
        
        println(result)
    }
}

*/