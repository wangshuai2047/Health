//
//  ResultProtocol.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

protocol ResultProtocol {
    var dataId: String { get set }
    var userId: Int { get set }
}

protocol ScaleResultProtocol: ResultProtocol {
    // true 男 false 女
    var gender: Bool { get set }
    var age: UInt8 { get set }
    var height: UInt8 { get set }
    
    // 体重
    var weight: Float { get set }
    // 水分率
    var waterPercentage: Float { get set }
    // 内脏脂肪率
    var visceralFatPercentage: Float { get set }
    
    // 体脂率
    var fatPercentage: Float { get set }
    // 脂肪重
    var fatWeight: Float { get set }
    // 水分重
    var waterWeight: Float { get set }
    // 肌肉重
    var muscleWeight: Float { get set }
    // 蛋白质重
    var proteinWeight: Float { get set }
    // 骨重
    var boneWeight: Float { get set }
    // 骨骼肌
    var boneMuscleWeight: Float { get set }
    
    // 健康评分
    var score: Float { get set }
    
    // 计算身体年龄
    var bodyAge: Float { get set }
    
    
    var waterWeightRange: (Float, Float) { get set }
    var proteinWeightRange: (Float, Float) { get set }
    var boneWeightRange: (Float, Float) { get set }
    var weightRange: (Float, Float) { get set }
    var fatWeightRange: (Float, Float) { get set }
    var muscleWeightRange: (Float, Float) { get set }
    var visceralFatContentRange: (Float, Float) { get set }
    var fatPercentageRange: (Float, Float) { get set }
    var BMIRange: (Float, Float) { get set }
    
    // 基础代谢
    var BMR: Float { get set }
    
    // 体质指数
    var BMI: Float { get set }
    
    // 标准体重 = S
    var SW: Float { get set }
    
    // 去脂体重
    var LBM: Float { get set }
    
    // 脂肪控制量
    var fatControl: Float { get set }
    
    // 标准肌肉
    var m_smm: Float { get set }
    
    // 肌肉控制量
    var muscleControl: Float { get set }
    
    // 标准体脂率
    var standardFatPercentage: Float { get set }
}

protocol BraceletResultProtocol: ResultProtocol {
    
    var results: [BraceletData] { get set }
    var device_model: Int { get set } // 设备类型
    var firm_ver: UInt16 { get set } // 固件版本号
    var percent: UInt8 { get set }  // 电池电量}
}
