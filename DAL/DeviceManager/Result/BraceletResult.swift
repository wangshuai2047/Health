//
//  BraceletResult.swift
//  Health
//
//  Created by Yalin on 15/9/3.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct BraceletData {
    
    var userId: Int
    var dataId: String
    
    var startTime: NSDate
    var endTime: NSDate
    var steps: UInt16        // 运动数量
    var stepsType: StepsType    // 运动类型  走路 10, 跑步 11, 睡觉 9
    
    init(userId: Int, startTime: NSDate, endTime: NSDate, steps: UInt16, stepsType: UInt16) {
        dataId = NSUUID().UUIDString
        
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.steps = steps
        
        if stepsType != 10 && stepsType != 11 && stepsType != 9 {
            self.stepsType = .Sleep
        }
        else {
            self.stepsType = StepsType(rawValue: stepsType)!
        }
        
    }
}

struct BraceletResult: BraceletResultProtocol {
    
    var userId: Int = 0
    var dataId: String = ""
    
    var results: [BraceletData] = []
    
    var device_model: Int = 0 // 设备类型
    var firm_ver: UInt16 = 0 // 固件版本号
    var percent: UInt8 = 0  // 电池电量
}
