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
        case mini = 0x01
        case plus = 0x02
    }
    
    var packageHead: UInt8 = 0xBC //包头
    var packageEnd: Data {
        return Data(bytes: [UInt8(0xD4), UInt8(0xC6), UInt8(0xC8), UInt8(0xD4)])
    }
    
    // 上行数据
    var type: DeviceType = .mini // 设备类型  0x01 mini  0x02 plus
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
    
    init(data: Data) {
        
        var index: Int = 1
        // type
        var tt: UInt8 = 0
        data.getBytes(buffer: &tt, range: NSRange(location: index, length: 1))
        type = DeviceType(rawValue: tt)!
        index += 1
        
        // cmd
        var cc: UInt8 = 0
        data.getBytes(buffer: &cc, range: NSRange(location: index, length: 1))
        cmd = CMD(rawValue: cc)!
        index += 1
        
        // resultCode
        data.getBytes(buffer: &resultCode, range: NSRange(location: index, length: 1))
        index += 1
        
        // 数据
        while (true) {
            var bytes = [UInt8](repeating: 0, count: 4)
            // copy bytes into array
            (data as NSData).getBytes(&bytes, range: NSRange(location: index, length: 4))
            
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
    
    fileprivate func headPackageData() -> Data {
        return Data(bytes: UnsafePointer<UInt8>([packageHead, type.rawValue, cmd.rawValue]), count: 3)
    }
    
    func toSetUserData(_ gender: Bool, age: UInt8, height: UInt8) -> Data {
        
        var data = NSData(data: headPackageData()) as Data
        
        // 性别(0x30 表示女性,0x31 表示男性) + 年龄 + 身高
        data.append(Data(bytes: UnsafePointer<UInt8>([0x03, gender ? 0x31 : 0x30, age, height]), count: 4))
        data.append(packageEnd)
        
        return data
    }
    
    func toReceiveWeightData() -> Data {
        
        var data = NSData(data: headPackageData()) as Data
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0x00)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xD4)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xC6)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xC8)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xD4)]), count: 1))
//        data.appendData(packageEnd)
//        print(packageEnd)
//        , , ,
        return data
    }
    
    func toReceiveBodyData() -> Data {
        var data = NSData(data: headPackageData()) as Data
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0x00)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xD4)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xC6)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xC8)]), count: 1))
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0xD4)]), count: 1))
//        data.appendData(packageEnd)
        
        return data
    }
    
    func toSetDeviceNameData() -> Data {
        var data = NSData(data: headPackageData()) as Data
        data.append(Data(bytes: UnsafePointer<UInt8>([UInt8(0x00)]), count: 1))
        data.append(packageEnd)
        
        return data
    }
}
