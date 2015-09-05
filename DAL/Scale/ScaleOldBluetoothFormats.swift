//
//  ScaleOldBluetoothFormats.swift
//  Health
//
//  Created by Yalin on 15/9/4.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

class ScaleOldBluetoothFormats: NSObject {
   
}

struct ScaleOldUserFormat {
    var commandType: UInt8 = 0x10
    var userId: UInt8 = UserData.shareInstance().userId!
    var gender: Bool = UserData.shareInstance().gender!
    var age: UInt8 = UserData.shareInstance().age!
    var height: UInt8 = UserData.shareInstance().height!
    
    func toData() -> NSData {
        var bytes = [UInt8](count: 5, repeatedValue: 0)
        
        
        
        bytes[0] = commandType
        bytes[1] = userId
        bytes[2] = gender ? 0x00 : 0x01
        bytes[3] = age
        bytes[4] = height
        
        return NSData(bytes: bytes, length: 5)
    }
}

//struct ScaleOldResult {
//    var scaleType: Byte
//}
