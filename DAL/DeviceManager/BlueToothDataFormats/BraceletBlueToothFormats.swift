//
//  BraceletBlueToothFormats.swift
//  Health
//
//  Created by Yalin on 15/9/3.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct BraceletBlueToothFormats {
    
    static let appToDeviceCmdId: UInt16 = 20002
    static let deviceToAppCmdId: UInt16 = 10002
    
    static let requestTimeCmdId: UInt8 = 8
    static let responseTimeCmdId: UInt8 = 3
    static let sportCmdId: UInt8 = 13
    static let generalCmdId: UInt8 = 1
    static let batteryCmdId: UInt8 = 2
    
    var packageHead: BraceletPackageHead
    var packageBody: BraceletPackageBodyProtocol?
    var responseTime: Date?
    
    init(cmdId: UInt8, time: Date) {
        
        // 现在只有时间
        if cmdId == BraceletBlueToothFormats.responseTimeCmdId {
            // 现在只有时间
            packageHead = BraceletPackageHead(bMagicNumber: UInt8(0xFE), bVer: UInt8(1), nLength: UInt16(15), nCmdId: BraceletBlueToothFormats.appToDeviceCmdId, nSeq: UInt16(65))
            
            packageBody = BraceletTimeResPackageBody(time: time)
        }
        else if cmdId == BraceletBlueToothFormats.sportCmdId {
            packageHead = BraceletPackageHead(bMagicNumber: UInt8(0xFE), bVer: UInt8(1), nLength: UInt16(12), nCmdId: BraceletBlueToothFormats.appToDeviceCmdId, nSeq: UInt16(65))
            packageBody = BraceletSportResPackageBody()
        }
        else if cmdId == BraceletBlueToothFormats.generalCmdId {
            
            packageHead = BraceletPackageHead(bMagicNumber: UInt8(0xFE), bVer: UInt8(1), nLength: UInt16(12), nCmdId: BraceletBlueToothFormats.appToDeviceCmdId, nSeq: UInt16(65))
            packageBody = BraceletGeneralResPackageBody()
        }
        else {
            // 现在只有时间
            packageHead = BraceletPackageHead(bMagicNumber: UInt8(0xFE), bVer: UInt8(1), nLength: UInt16(15), nCmdId: BraceletBlueToothFormats.appToDeviceCmdId, nSeq: UInt16(65))
            
            packageBody = BraceletTimeResPackageBody(time: time)
        }
        
    }
    
    mutating func setSyncTime(_ date: Date) {
        responseTime = date
    }
    
    // data是包括包头的NSData对象
    mutating func setBodyData(_ data: Data) {
        var index: Int = 8
        
        // 解析包体
        var cmd_version: UInt8 = 0
        var cmd_type: UInt8 = 0
        (data as NSData).getBytes(&cmd_version, range: NSRange(location: index, length: 1))
        index += 1
        (data as NSData).getBytes(&cmd_type, range: NSRange(location: index, length: 1))
        index += 1
        
        if packageHead.nCmdId == BraceletBlueToothFormats.deviceToAppCmdId {
            // 设备发送给APP 请求命令
            if cmd_type == BraceletBlueToothFormats.requestTimeCmdId {
                // 请求时间包
                packageBody = BraceletTimeReqPackageBody()
            }
            else if cmd_type == BraceletBlueToothFormats.sportCmdId {
                // 运动步数包
                packageBody = BraceletSportReqPackageBody(frontIndex: index, data: data)
            }
            else if cmd_type == BraceletBlueToothFormats.generalCmdId {
                // 设备版本包
                packageBody = BraceletDeviceVersionReqPackageBody(frontIndex: index, data: data)
            }
            else if cmd_type == BraceletBlueToothFormats.batteryCmdId {
                // 设备电量包
                packageBody = BraceletBatteryReqPackageBody(frontIndex: index, data: data)
            }
        }
        else if packageHead.nCmdId == BraceletBlueToothFormats.appToDeviceCmdId {
            // APP发送给设备 反馈命令
            if cmd_type == BraceletBlueToothFormats.responseTimeCmdId {
                // 时间反馈包
                packageBody = BraceletTimeResPackageBody(time: responseTime!)
            }
            else if cmd_type == BraceletBlueToothFormats.sportCmdId {
                // 运动反馈包
                packageBody = BraceletSportResPackageBody()
            }
            else if cmd_type == BraceletBlueToothFormats.generalCmdId {
                // 通用反馈包
                packageBody = BraceletGeneralResPackageBody()
            }
        }
    }
    
    init(data: Data) {
        // 解析包头
        var bMagicNumber: UInt8 = 0
        var bVer: UInt8 = 0
        var nLength: UInt16 = 0
        var nCmdId: UInt16 = 0
        var nSeq: UInt16 = 0
        
        var index: Int = 0
        (data as NSData).getBytes(&bMagicNumber, range: NSRange(location: index, length: 1))
        index += 1
        (data as NSData).getBytes(&bVer, range: NSRange(location: index, length: 1))
        index += 1
        
        data.getUInt16Bytes(&nLength, range: NSRange(location: index, length: MemoryLayout<UInt16>.size))
        index += 2
        
        data.getUInt16Bytes(&nCmdId, range: NSRange(location: index, length: 2))
        index += 2
        data.getUInt16Bytes(&nSeq, range: NSRange(location: index, length: 2))
        index += 2
        
        packageHead = BraceletPackageHead(bMagicNumber: bMagicNumber, bVer: bVer, nLength: nLength, nCmdId: nCmdId, nSeq: nSeq)
        
//        setBodyData(data)
    }
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: Int(packageHead.nLength))
        
        bytes[0] = packageHead.bMagicNumber
        bytes[1] = packageHead.bVer
        
        bytes[2] = UInt8(((packageHead.nLength >> 8)&0xff))
        bytes[3] = UInt8(((packageHead.nLength >> 0)&0xff))
        
        bytes[4] = UInt8(((packageHead.nCmdId >> 8)&0xff))
        bytes[5] = UInt8(((packageHead.nCmdId >> 0)&0xff))
        
        bytes[6] = UInt8(((packageHead.nSeq >> 8)&0xff))
        bytes[7] = UInt8(((packageHead.nSeq >> 0)&0xff))
        
        var data = Data(bytes: bytes, count: 8)
        data.append(packageBody!.toData())
        
        return data
    }
}

struct BraceletPackageHead {
    var bMagicNumber: UInt8 = 0xFE
    var bVer: UInt8 = 1             // 包格式版本号
    var nLength: UInt16             // 为包头加包体的长度
    var nCmdId: UInt16              // 命令号：10002 设备发送给APP 20002 APP发送给设备
    var nSeq: UInt16                // 没发送一个包+1， 暂时可以不做处理
}


protocol BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { get }   // 协议子版本，目前默认0
    var cmd_type: UInt8 { get set }  // 命令类型
    func toData() -> Data
}

//请求时间包
struct BraceletTimeReqPackageBody: BraceletPackageBodyProtocol {
//    var device_model: UInt8     // 设备类型
    
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.requestTimeCmdId
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 2)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)
    }
}

//时间反馈包
struct BraceletTimeResPackageBody: BraceletPackageBodyProtocol {
    
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.responseTimeCmdId
    
    var time: Date
    var timezone: UInt8 {
        return UInt8(NSTimeZone.system.secondsFromGMT() / 60 / 60)
    }
    
    init(time: Date) {
        self.time = time
    }
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 7)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        let timescamp: Int = Int(time.timeIntervalSince1970)
        bytes[2] = UInt8(((timescamp >> 24) & 0xff))
        bytes[3] = UInt8(((timescamp >> 16) & 0xff))
        bytes[4] = UInt8(((timescamp >> 8) & 0xff))
        bytes[5] = UInt8(((timescamp >> 8) & 0xff))
        
        bytes[6] = timezone
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 7)
    }
}

// 运动请求包
struct BraceletSportReqPackageBody: BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.sportCmdId
    
    var step_count: UInt16 = 0
    var start_time: Date
    
    struct SportData {
        var end_time: Date
        var steps: UInt16
        var stepsType: UInt16
    }
    
    var info: [SportData]
    
    init(frontIndex: Int, data: Data) {
        
        var index: Int = frontIndex
        data.getBytes(buffer:&step_count, range: NSRange(location: index, length: 2))
        index+=2
        var startTimeScamp: UInt32 = 0
        data.getBytes(buffer:&startTimeScamp, range: NSRange(location: index, length: 4))
        index+=4
        start_time = Date(timeIntervalSince1970: TimeInterval(startTimeScamp))
        
        info = []
        for _ in 0...step_count-1 {
            var endTime: UInt32 = 0
            var steps: UInt16 = 0
            var stepsType: UInt16 = 0
            
            data.getBytes(buffer: &endTime, range: NSRange(location: index, length: 4))
            index+=4
            data.getBytes(buffer: &steps, range: NSRange(location: index, length: 2))
            index+=2
            data.getBytes(buffer: &stepsType, range: NSRange(location: index, length: 2))
            index+=2
            
            info.append(SportData(end_time: Date(timeIntervalSince1970: TimeInterval(endTime)), steps: steps, stepsType: stepsType))
        }
    }
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 2)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)
    }
}

// 运动反馈包
struct BraceletSportResPackageBody: BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.sportCmdId
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 4)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 4)
    }
}

// 设备版本包
struct BraceletDeviceVersionReqPackageBody: BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.generalCmdId
    var firm_ver: UInt16 = 0    // 固件版本号
    var device_model: Int = 0   // 设备类型
    
    init(frontIndex: Int, data: Data) {
        
        var index: Int = frontIndex
        data.getBytes(buffer:&firm_ver, range: NSRange(location: index, length: 2))
        index+=2
        
        data.getBytes(buffer: &device_model, range: NSRange(location: index, length: 3))
    }
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 2)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)
    }
}

// 通用反馈包
struct BraceletGeneralResPackageBody: BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.generalCmdId
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 4)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 4)
    }
}

// 设备电量包
struct BraceletBatteryReqPackageBody: BraceletPackageBodyProtocol {
    var cmd_version: UInt8 { return 0 }
    var cmd_type: UInt8 = BraceletBlueToothFormats.batteryCmdId
    
    var percent: UInt8 = 0
    var Unused: UInt8 = 0
    var battery_voltage: UInt16 = 0
    
    init(frontIndex: Int, data: Data) {
        
        var index: Int = frontIndex
        data.getBytes(buffer:&percent, range: NSRange(location: index, length: 1))
        index+=1
        
        data.getBytes(buffer: &Unused, range: NSRange(location: index, length: 1))
        index+=1
        
        data.getBytes(buffer: &battery_voltage, range: NSRange(location: index, length: 2))
    }
    
    func toData() -> Data {
        
        var bytes = [UInt8](repeating: 0, count: 2)
        
        bytes[0] = cmd_version
        bytes[1] = cmd_type
        
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 2)
    }
}
