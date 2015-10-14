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
    
    
    // 水分率
    var waterPercentage: Float { get set }
    // 体重
    var weight: Float { get set }
    var weightRange: (Float, Float) { get set }
    // 脂肪肝 nil代表不支持
    var hepaticAdiposeInfiltration: Bool? { get set }
    // 去脂体重
    var LBM: Float { get set }
    // 标准体脂率
    var standardFatPercentage: Float { get set }
    
    
    // 瘦体重
    var fatFreeBodyWeight: Float { get set }
    // 瘦体重正常范围下限 + 瘦体重正常范围上限
    var fatFreeBodyWeightRange: (Float, Float) { get set }
    
    // 肌肉重
    var muscleWeight: Float { get set }
    // 肌肉重正常范围下限 + 肌肉重正常范围上限
    var muscleWeightRange: (Float, Float) { get set }
    
    // 蛋白质重
    var proteinWeight: Float { get set }
    // 蛋白质正常范围下限 + 蛋白质正常范围上限
    var proteinWeightRange: (Float, Float) { get set }
    
    // 骨重
    var boneWeight: Float { get set }
    // 骨质重正常范围下限 + 骨质重正常范围上限
    var boneWeightRange: (Float, Float) { get set }
    
    // 水分重
    var waterWeight: Float { get set }
    // 细胞总水正常范围下限 + 细胞总水正常范围上限
    var waterWeightRange: (Float, Float) { get set }
    
    // 脂肪重
    var fatWeight: Float { get set }
    // 脂肪重正常范围下限 + 脂肪重正常范围上限
    var fatWeightRange: (Float, Float) { get set }
    
    // 体脂率
    var fatPercentage: Float { get set }
    // 体脂百分比正常范围下限 + 体脂百分比正常范围上限
    var fatPercentageRange: (Float, Float) { get set }
    
    // 腰臀比(两位小数)
    var WHR: Float { get set }
    // 腰臀比正常范围下限 + 腰臀比正常范围上限
    var WHRRange: (Float, Float) { get set }
    
    // 内脏脂肪率 = 0
    var visceralFatPercentage: Float { get set }
    var visceralFatContentRange: (Float, Float) { get set }
    
    // 体质指数
    var BMI: Float { get set }
    // 体质指数正常范围下限 + 体质指数正常范围上限
    var BMIRange: (Float, Float) { get set }
    
    // 基础代谢率
    var BMR: Float { get set }
    
    // 身体年龄
    var bodyAge: Float { get set }
    
    // 骨骼肌
    var boneMuscleWeight: Float { get set }
    // 骨骼肌正常范围下限 + 骨骼肌正常范围上限
    var boneMuscleRange: (Float, Float) { get set }
    
    // 肌肉控制(有符号)
    var muscleControl: Float { get set }
    
    // 脂肪控制(有符号)
    var fatControl: Float { get set }
    
    // 体重控制(有符号)
    var weightControl: Float { get set }
    
    // 标准体重
    var SW: Float { get set }
    // 标准体重正常范围下限 + 标准体重正常范围上限
    var SWRange: (Float, Float) { get set }
    
    // 目标体重
    var goalWeight: Float { get set }
    
    // 标准肌肉
    var m_smm: Float { get set }
    
    // 右上肢脂肪
    var rightUpperExtremityFat: Float { get set }
    
    // 右上肢肌肉
    var rightUpperExtremityMuscle: Float { get set }
    
    // 右上肢骨质
    var rightUpperExtremityBone: Float { get set }
    
    // 左上肢脂肪
    var leftUpperExtremityFat: Float { get set }
    
    // 左上肢肌肉
    var leftUpperExtremityMuscle: Float { get set }
    
    // 左上肢骨质
    var leftUpperExtremityBone: Float { get set }
    
    // 躯干肢脂肪
    var trunkLimbFat: Float { get set }
    
    // 躯干肢肌肉
    var trunkLimbMuscle: Float { get set }
    
    // 躯干肢骨质
    var trunkLimbBone: Float { get set }
    
    // 右下肢脂肪
    var rightLowerExtremityFat: Float { get set }
    
    // 右下肢肌肉
    var rightLowerExtremityMuscle: Float { get set }
    
    // 右下肢骨质
    var rightLowerExtremityBone: Float { get set }
    
    // 左下肢脂肪
    var leftLowerExtremityFat: Float { get set }
    
    // 左下肢肌肉
    var leftLowerExtremityMuscle: Float { get set }
    
    // 左下肢骨质
    var leftLowerExtremityBone: Float { get set }
    
    // 健康得分
    var score: Float { get set }
}

protocol BraceletResultProtocol: ResultProtocol {
    
    var results: [BraceletData] { get set }
    var device_model: Int { get set } // 设备类型
    var firm_ver: UInt16 { get set } // 固件版本号
    var percent: UInt8 { get set }  // 电池电量}
}
