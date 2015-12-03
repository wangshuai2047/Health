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
    }
    
    enum DeviceType: UInt8 {
        case Mini = 0x01
        case Plus = 0x02
    }
    
    var packageHead: UInt8 = 0xBC //包头
    var packageEnd: NSData {
        return NSData(bytes: [UInt8(0xD4), UInt8(0xC6), UInt8(0xC8), UInt8(0xD4)], length: 4)
    }
    
    // 上行数据
    var type: DeviceType = .Mini // 设备类型  0x01 mini  0x02 plus
    var cmd: CMD = .weightData  // 命令字  0x02 称重数据  0x03 身体成分数据
    var resultCode: UInt8 = 0x30 // 结果码 只在 bodyData 命令时有效,0x30 表示没有脂肪肝,0x31 表示有脂肪肝,0x33 测试 失败
    var datas: [Float] = []
    
    // 下行数据
    var weight: Float {
        if self.datas.count > 0 {
            return self.datas[0]
        }
        return 0
    }// 体重
    
    var length: UInt8 = 0
    
    init(cmd: CMD) {
        self.cmd = cmd
    }
    
    init(data: NSData) {
        
        var index: Int = 1
        // type
        var tt: UInt8 = 0
        data.getBytes(buffer: &tt, range: NSRange(location: index, length: 1))
        type = DeviceType(rawValue: tt)!
        index++
        
        // cmd
        var cc: UInt8 = 0
        data.getBytes(buffer: &cc, range: NSRange(location: index, length: 1))
        cmd = CMD(rawValue: cc)!
        index++
        
        // resultCode
        data.getBytes(buffer: &resultCode, range: NSRange(location: index, length: 1))
        index++
        
        // 数据
        while (true) {
            var bytes = [UInt8](count: 4, repeatedValue: 0)
            // copy bytes into array
            data.getBytes(&bytes, range: NSRange(location: index, length: 4))
            
            if bytes[0] == 0xD4 && bytes[1] == 0xC6 && bytes[2] == 0xC8 && bytes[3] == 0xD4 {
                // 包尾结束
                break
            }
            
            let symbol: Float = bytes[0] == 0x00 ? 1 : -1
            let thousandNumber: Float = Float(bytes[1]) * 100
            let tenNumber: Float = Float(bytes[2])
            let decimalNumber: Float = Float(bytes[3]) / 100
            
            datas.append(symbol * (thousandNumber + tenNumber + decimalNumber))
            
            index += 4
        }
    }
    
    private func headPackageData() -> NSData {
        return NSData(bytes: [packageHead, type.rawValue, cmd.rawValue], length: 3)
    }
    
    func toSetUserData(gender: Bool, age: UInt8, height: UInt8) -> NSData {
        
        let data = NSMutableData(data: headPackageData())
        
        // 性别(0x30 表示女性,0x31 表示男性) + 年龄 + 身高
        data.appendData(NSData(bytes: [0x03, gender ? 0x31 : 0x30, age, height], length: 4))
        data.appendData(packageEnd)
        
        return data
    }
    
    func toReceiveWeightData() -> NSData {
        
        let data = NSMutableData(data: headPackageData())
        data.appendData(NSData(bytes: [UInt8(0x00)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xD4)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xC6)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xC8)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xD4)], length: 1))
//        data.appendData(packageEnd)
//        print(packageEnd)
//        , , ,
        return data
    }
    
    func toReceiveBodyData() -> NSData {
        let data = NSMutableData(data: headPackageData())
        data.appendData(NSData(bytes: [UInt8(0x00)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xD4)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xC6)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xC8)], length: 1))
        data.appendData(NSData(bytes: [UInt8(0xD4)], length: 1))
//        data.appendData(packageEnd)
        
        return data
    }
    
    func toSetDeviceNameData() -> NSData {
        let data = NSMutableData(data: headPackageData())
        data.appendData(NSData(bytes: [UInt8(0x00)], length: 1))
        data.appendData(packageEnd)
        
        return data
    }
}