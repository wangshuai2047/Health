//
//  MyBodyMiniResult.swift
//  Health
//
//  Created by Yalin on 15/10/13.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

struct MyBodyMiniAndPlusResult: ScaleResultProtocol {
    var dataId: String
    var userId: Int
    
    // true 男 false 女
    var gender: Bool
    var age: UInt8
    var height: UInt8
    
    
    // 水分率
    var waterPercentage: Float
    // 体重
    var weight: Float
    // 脂肪肝 nil代表不支持
    var hepaticAdiposeInfiltration: Bool?
    

    // 瘦体重
    var fatFreeBodyWeight: Float
    // 瘦体重正常范围下限 + 瘦体重正常范围上限
    var fatFreeBodyWeightRange: (Float, Float)
    
    // 肌肉重
    var muscleWeight: Float
    // 肌肉重正常范围下限 + 肌肉重正常范围上限
    var muscleWeightRange: (Float, Float)
    
    // 蛋白质重
    var proteinWeight: Float
    // 蛋白质正常范围下限 + 蛋白质正常范围上限
    var proteinWeightRange: (Float, Float)
    
    // 骨重
    var boneWeight: Float
    // 骨质重正常范围下限 + 骨质重正常范围上限
    var boneWeightRange: (Float, Float)
    
    // 水分重
    var waterWeight: Float
    // 细胞总水正常范围下限 + 细胞总水正常范围上限
    var waterWeightRange: (Float, Float)
    
    // 脂肪重
    var fatWeight: Float
    // 脂肪重正常范围下限 + 脂肪重正常范围上限
    var fatWeightRange: (Float, Float)
    
    // 体脂率
    var fatPercentage: Float
    // 体脂百分比正常范围下限 + 体脂百分比正常范围上限
    var fatPercentageRange: (Float, Float)
    
    // 腰臀比(两位小数)
    // 腰臀比正常范围下限 + 腰臀比正常范围上限
    
    // 内脏脂肪率
    var visceralFatPercentage: Float
    
    // 体质指数
    var BMI: Float
    // 体质指数正常范围下限 + 体质指数正常范围上限
    var BMIRange: (Float, Float)
    
    // 基础代谢率
    var BMR: Float
    
    // 身体年龄
    var bodyAge: Float
    
    // 骨骼肌
    var boneMuscleWeight: Float
    // 骨骼肌正常范围下限 + 骨骼肌正常范围上限
    var boneMuscleRange: (Float, Float)
    
    // 肌肉控制(有符号)
    var muscleControl: Float
    
    // 脂肪控制(有符号)
    var fatControl: Float
    
    // 体重控制(有符号)
    var weightControl: Float
    
    // 标准体重
    var SW: Float
    // 标准体重正常范围下限 + 标准体重正常范围上限
    var SWRange: (Float, Float)
    
    // 目标体重
    var goalWeight: Float
    
    // 标准肌肉
    var m_smm: Float
    
    // 右上肢脂肪
    
    // 右上肢肌肉
    
    // 右上肢骨质
    
    // 左上肢脂肪
    
    // 左上肢肌肉
    
    // 左上肢骨质
    
    // 躯干肢脂肪
    
    // 躯干肢肌肉
    
    // 躯干肢骨质
    
    // 右下肢脂肪
    
    // 右下肢肌肉
    
    // 右下肢骨质
    
    // 左下肢脂肪
    
    // 左下肢肌肉
    
    // 左下肢骨质
    
    // 健康得分
    var score: Float
    
}