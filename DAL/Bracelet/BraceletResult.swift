//
//  BraceletResult.swift
//  Health
//
//  Created by Yalin on 15/9/3.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct BraceletResult {
    
    enum StepsType: UInt16 {
        case Walk = 10
        case Run = 11
        case Sleep = 9
    }
    
//    var deviceModel: 
    var userId: UInt16
    var dataId: String
    
    var startTime: NSDate
    var endTime: NSDate
    var steps: UInt16        // 运动数量
    var stepsType: StepsType    // 运动类型  走路 10, 跑步 11, 睡觉 9
    
    init(userId: UInt16, startTime: NSDate, endTime: NSDate, steps: UInt16, stepsType: UInt16) {
        dataId = NSUUID().UUIDString
        
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.steps = steps
        self.stepsType = StepsType(rawValue: stepsType)!
    }
}
