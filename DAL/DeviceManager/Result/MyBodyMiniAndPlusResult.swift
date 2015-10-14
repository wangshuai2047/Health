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
    var waterPercentage: Float = 0
    // 体重
    var weight: Float = 0
    // 脂肪肝 nil代表不支持
    var hepaticAdiposeInfiltration: Bool?
    

    // 瘦体重
    var fatFreeBodyWeight: Float = 0
    // 瘦体重正常范围下限 + 瘦体重正常范围上限
    var fatFreeBodyWeightRange: (Float, Float) = (0,0)
    
    // 肌肉重
    var muscleWeight: Float = 0
    // 肌肉重正常范围下限 + 肌肉重正常范围上限
    var muscleWeightRange: (Float, Float) = (0,0)
    
    // 蛋白质重
    var proteinWeight: Float = 0
    // 蛋白质正常范围下限 + 蛋白质正常范围上限
    var proteinWeightRange: (Float, Float) = (0,0)
    
    // 骨重
    var boneWeight: Float = 0
    // 骨质重正常范围下限 + 骨质重正常范围上限
    var boneWeightRange: (Float, Float) = (0,0)
    
    // 水分重
    var waterWeight: Float = 0
    // 细胞总水正常范围下限 + 细胞总水正常范围上限
    var waterWeightRange: (Float, Float) = (0,0)
    
    // 脂肪重
    var fatWeight: Float = 0
    // 脂肪重正常范围下限 + 脂肪重正常范围上限
    var fatWeightRange: (Float, Float) = (0,0)
    
    // 体脂率
    var fatPercentage: Float = 0
    // 体脂百分比正常范围下限 + 体脂百分比正常范围上限
    var fatPercentageRange: (Float, Float) = (0,0)
    
    // 腰臀比(两位小数)
    var WHR: Float = 0
    // 腰臀比正常范围下限 + 腰臀比正常范围上限
    var WHRRange: (Float, Float) = (0,0)
    
    // 内脏脂肪率 = 0
    var visceralFatPercentage: Float = 0
    
    // 体质指数
    var BMI: Float = 0
    // 体质指数正常范围下限 + 体质指数正常范围上限
    var BMIRange: (Float, Float) = (0,0)
    
    // 基础代谢率
    var BMR: Float = 0
    
    // 身体年龄
    var bodyAge: Float = 0
    
    // 骨骼肌
    var boneMuscleWeight: Float = 0
    // 骨骼肌正常范围下限 + 骨骼肌正常范围上限
    var boneMuscleRange: (Float, Float) = (0,0)
    
    // 肌肉控制(有符号)
    var muscleControl: Float = 0
    
    // 脂肪控制(有符号)
    var fatControl: Float = 0
    
    // 体重控制(有符号)
    var weightControl: Float = 0
    
    // 标准体重
    var SW: Float = 0
    // 标准体重正常范围下限 + 标准体重正常范围上限
    var SWRange: (Float, Float) = (0,0)
    
    // 目标体重
    var goalWeight: Float = 0
    
    // 标准肌肉
    var m_smm: Float = 0
    
    // 右上肢脂肪
    var rightUpperExtremityFat: Float = 0
    
    // 右上肢肌肉
    var rightUpperExtremityMuscle: Float = 0
    
    // 右上肢骨质
    var rightUpperExtremityBone: Float = 0
    
    // 左上肢脂肪
    var leftUpperExtremityFat: Float = 0
    
    // 左上肢肌肉
    var leftUpperExtremityMuscle: Float = 0
    
    // 左上肢骨质
    var leftUpperExtremityBone: Float = 0
    
    // 躯干肢脂肪
    var trunkLimbFat: Float = 0
    
    // 躯干肢肌肉
    var trunkLimbMuscle: Float = 0
    
    // 躯干肢骨质
    var trunkLimbBone: Float = 0
    
    // 右下肢脂肪
    var rightLowerExtremityFat: Float = 0
    
    // 右下肢肌肉
    var rightLowerExtremityMuscle: Float = 0
    
    // 右下肢骨质
    var rightLowerExtremityBone: Float = 0
    
    // 左下肢脂肪
    var leftLowerExtremityFat: Float = 0
    
    // 左下肢肌肉
    var leftLowerExtremityMuscle: Float = 0
    
    // 左下肢骨质
    var leftLowerExtremityBone: Float = 0
    
    // 健康得分
    var score: Float = 0
    
    init?(dataId: String, userId: Int, gender: Bool, age: UInt8, height: UInt8) {
        
        self.dataId = dataId
        self.userId = userId
        self.gender = gender
        self.age = age
        self.height = height
    }
    
    mutating func setDatas(datas: [Float]) {
        
        if datas.count < 57 {
            return
        }
        
        var index = 0
        
        // 瘦体重
        fatFreeBodyWeight = datas[index++]
        
        // 瘦体重正常范围下限 + 瘦体重正常范围上限
        fatFreeBodyWeightRange = (datas[index++], datas[index++])
        
        // 肌肉重
        muscleWeight = datas[index++]
        // 肌肉重正常范围下限 + 肌肉重正常范围上限
        muscleWeightRange = (datas[index++], datas[index++])
        
        // 蛋白质重
        proteinWeight = datas[index++]
        // 蛋白质正常范围下限 + 蛋白质正常范围上限
        proteinWeightRange = (datas[index++], datas[index++])
        
        // 骨重
        boneWeight = datas[index++]
        // 骨质重正常范围下限 + 骨质重正常范围上限
        boneWeightRange = (datas[index++], datas[index++])
        
        // 水分重
        waterWeight = datas[index++]
        // 细胞总水正常范围下限 + 细胞总水正常范围上限
        waterWeightRange = (datas[index++], datas[index++])
        
        // 脂肪重
        fatWeight = datas[index++]
        // 脂肪重正常范围下限 + 脂肪重正常范围上限
        fatWeightRange = (datas[index++], datas[index++])
        
        // 体脂率
        fatPercentage = datas[index++]
        // 体脂百分比正常范围下限 + 体脂百分比正常范围上限
        fatPercentageRange = (datas[index++], datas[index++])
        
        // 腰臀比(两位小数)
        WHR = datas[index++]
        // 腰臀比正常范围下限 + 腰臀比正常范围上限
        WHRRange = (datas[index++], datas[index++])
        
        // 内脏脂肪率
        visceralFatPercentage = datas[index++]
        
        // 体质指数
        BMI = datas[index++]
        // 体质指数正常范围下限 + 体质指数正常范围上限
        BMIRange = (datas[index++], datas[index++])
        
        // 基础代谢率
        BMR = datas[index++]
        
        // 身体年龄
        bodyAge = datas[index++]
        
        // 骨骼肌
        boneMuscleWeight = datas[index++]
        // 骨骼肌正常范围下限 + 骨骼肌正常范围上限
        boneMuscleRange = (datas[index++], datas[index++])
        
        // 肌肉控制(有符号)
        muscleControl = datas[index++]
        
        // 脂肪控制(有符号)
        fatControl = datas[index++]
        
        // 体重控制(有符号)
        weightControl = datas[index++]
        
        // 标准体重
        SW = datas[index++]
        // 标准体重正常范围下限 + 标准体重正常范围上限
        SWRange = (datas[index++], datas[index++])
        
        // 目标体重
        goalWeight = datas[index++]
        
        // 标准肌肉
        m_smm = datas[index++]
        
        // 右上肢脂肪
        rightUpperExtremityFat = datas[index++]
        
        // 右上肢肌肉
        rightUpperExtremityMuscle = datas[index++]
        
        // 右上肢骨质
        rightUpperExtremityBone = datas[index++]
        
        // 左上肢脂肪
        leftUpperExtremityFat = datas[index++]
        
        // 左上肢肌肉
        leftUpperExtremityMuscle = datas[index++]
        
        // 左上肢骨质
        leftUpperExtremityBone = datas[index++]
        
        // 躯干肢脂肪
        trunkLimbFat = datas[index++]
        
        // 躯干肢肌肉
        trunkLimbMuscle = datas[index++]
        
        // 躯干肢骨质
        trunkLimbBone = datas[index++]
        
        // 右下肢脂肪
        rightLowerExtremityFat = datas[index++]
        
        // 右下肢肌肉
        rightLowerExtremityMuscle = datas[index++]
        
        // 右下肢骨质
        rightLowerExtremityBone = datas[index++]
        
        // 左下肢脂肪
        leftLowerExtremityFat = datas[index++]
        
        // 左下肢肌肉
        leftLowerExtremityMuscle = datas[index++]
        
        // 左下肢骨质
        leftLowerExtremityBone = datas[index++]
        
        // 健康得分
        score = datas[index++]
    }
}