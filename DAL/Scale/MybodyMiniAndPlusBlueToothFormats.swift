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
        case needSetUserData = 0x81
        case needw
    }
    
    var packageHead: UInt8 = 0xBC //包头
    var packageEnd: UInt32 = 0xD4C6C8D4
    
    // 上行数据
    var UUID: UInt16 = 0xbca1
    var type: UInt8                 // 设备类型  0x01 mini  0x02 plus
    var cmd: UInt8  // 命令字  0x02 称重数据  0x03 身体成分数据
    var resultCode: UInt8 // 结果码 只在 0x03 命令时有效,0x30 表示没有脂肪肝,0x31 表示有脂肪肝,0x33 测试 失败
    
    var upDatas: [Int32]
    
    
    
    
    // 下行数据
    
    var weight: Int32   // 体重
}