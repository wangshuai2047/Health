//
//  MybodyMiniAndPlusBlueToothFormats.swift
//  Health
//
//  Created by Yalin on 15/10/11.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

struct MybodyMiniAndPlusBlueToothFormats {
    
    enum CMD: UInt8 {
        case weightData = 0x02
        case bodyData = 0x03
        case setUserData = 0x81
        case receiveWeightData = 0x82
        case receiveBodyData = 0x83
        case setDeviceName = 0x84
        
        
        func testData(cmd: CMD) -> NSData {
            switch self {
            case .setUserData:
                return NSData()
            default:
                return NSData()
            }
        }
    }
    
    var packageHead: UInt8 = 0xBC //包头
    var packageEnd: UInt32 = 0xD4C6C8D4
    
    // 上行数据
    var UUID: UInt16 = 0xbca1
    var type: UInt8                 // 设备类型  0x01 mini  0x02 plus
    var cmd: CMD  // 命令字  0x02 称重数据  0x03 身体成分数据
    var resultCode: UInt8 // 结果码 只在 0x03 命令时有效,0x30 表示没有脂肪肝,0x31 表示有脂肪肝,0x33 测试 失败
    
    var upDatas: [Int32]
    
    
    
    
    // 下行数据
    var weight: Int32   // 体重
    
    
//    init(cmd: CMD, data: NSData?) {
//        self.cmd
//    }
    
    static func toSetUserData(cmd: CMD) -> NSData {
        
        var bytes = [UInt8](count: Int(11), repeatedValue: 0)
        
        bytes[0] = 0xbc
        bytes[1] = 0x01
        
        bytes[2] = 0x81
        
        bytes[3] = 0x03
        // 性别(0x30 表示女性,0x31 表示男性) + 年龄 + 身高
        bytes[4] = 0x30
        
        bytes[5] = 0x19
        bytes[6] = 0xa8
        
        // 0xD4 C6 C8 D4
        bytes[7] = 0xd4
        bytes[8] = 0xc6
        bytes[9] = 0xc8
        bytes[10] = 0xd4
        
        let data = NSMutableData(bytes: bytes, length: 11)
        
        return data
    }
    
//    static func toReceiveWeightData() -> NSData {
//        
//    }
//    
//    static func
}