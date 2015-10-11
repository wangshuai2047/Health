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
    
    func syncBraceletDatas(beginDate: NSDate, syncComplete: (([BraceletResult], NSError?) -> Void)) {
        var uuid: String? = nil
        if let (id, _) = DBManager.shareInstance().braceletInfo() {
            uuid = id
        }
        
        braceletManager.syncData(beginDate, deviceUUID: uuid, syncComplete: syncComplete)
    }
    
    func startScale(complete: (result: ScaleResultProtocol?, err: NSError?) -> Void) {
        scaleHelper.startScale(complete)
    }
    
    func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol {
        return ScaleOld.scaleInputData(weight, waterContent: waterContent, visceralFatContent: visceralFatContent, gender: gender, userId: userId, age: age, height: height)
    }
}