//
//  ScaleResult.swift
//  Health
//
//  Created by Yalin on 15/8/29.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct ScaleResult {
    
    var dataId: String
    
    var userId: Int
    // true 男 false 女
    var gender: Bool
    var age: UInt8
    var height: UInt8
    
    // 体重
    var weight: Float
    // 水分率
    var waterPercentage: Float
    // 内脏脂肪率
    var visceralFatPercentage: Float
    
    // 体脂率
    var fatPercentage: Float
    // 脂肪重
    var fatWeight: Float
    // 水分重
    var waterWeight: Float
    // 肌肉重
    var muscleWeight: Float
    // 蛋白质重
    var proteinWeight: Float
    // 骨重
    var boneWeight: Float
    // 骨骼肌
    var boneMuscleWeight: Float
    
    
    init(userId: Int, gender: Bool, age: UInt8, height: UInt8, weight: Float, waterContent: Float, visceralFatContent: Float, fatPercentage: Float, fatWeight: Float, waterWeight: Float, muscleWeight: Float, proteinWeight: Float, boneWeight: Float, boneMuscleWeight: Float) {
        dataId = NSUUID().UUIDString
        
        self.userId = userId
        self.gender = gender
        self.age = age
        self.height = height
        
        self.weight = weight
        self.waterPercentage = waterContent
        self.visceralFatPercentage = visceralFatContent
        
        self.fatPercentage = fatPercentage
        self.fatWeight = fatWeight
        self.waterWeight = waterWeight
        self.muscleWeight = muscleWeight
        self.proteinWeight = proteinWeight
        self.boneWeight = boneWeight
        self.boneMuscleWeight = boneMuscleWeight
    }
}

extension ScaleResult {
    
    init(info: [String: NSObject]) {
        
        dataId = info["dataId"] as! String
        userId = (info["userId"] as! NSNumber).integerValue
        weight = (info["weight"] as! NSNumber).floatValue
        waterPercentage = (info["waterPercentage"] as! NSNumber).floatValue
        visceralFatPercentage = (info["visceralFatPercentage"] as! NSNumber).floatValue
        fatPercentage = (info["fatPercentage"] as! NSNumber).floatValue
        fatWeight = (info["fatWeight"] as! NSNumber).floatValue
        waterWeight = (info["waterWeight"] as! NSNumber).floatValue
        muscleWeight = (info["muscleWeight"] as! NSNumber).floatValue
        proteinWeight = (info["proteinWeight"] as! NSNumber).floatValue
        boneWeight = (info["boneWeight"] as! NSNumber).floatValue
        boneMuscleWeight = (info["boneMuscleWeight"] as! NSNumber).floatValue
        
        gender = UserData.shareInstance().gender!
        age = UserData.shareInstance().age!
        height = UserData.shareInstance().height!
    }
    
    init(evaluationdata: EvaluationData) {
        
        dataId = evaluationdata.valueForKey("dataId") as! String
        userId = (evaluationdata.valueForKey("userId") as! NSNumber).integerValue
        weight = (evaluationdata.valueForKey("weight") as! NSNumber).floatValue
        waterPercentage = (evaluationdata.valueForKey("waterPercentage") as! NSNumber).floatValue
        visceralFatPercentage = (evaluationdata.valueForKey("visceralFatPercentage") as! NSNumber).floatValue
        fatPercentage = (evaluationdata.valueForKey("fatPercentage") as! NSNumber).floatValue
        fatWeight = (evaluationdata.valueForKey("fatWeight") as! NSNumber).floatValue
        waterWeight = (evaluationdata.valueForKey("waterWeight") as! NSNumber).floatValue
        muscleWeight = (evaluationdata.valueForKey("muscleWeight") as! NSNumber).floatValue
        proteinWeight = (evaluationdata.valueForKey("proteinWeight") as! NSNumber).floatValue
        boneWeight = (evaluationdata.valueForKey("boneWeight") as! NSNumber).floatValue
        boneMuscleWeight = (evaluationdata.valueForKey("boneMuscleWeight") as! NSNumber).floatValue
        
        gender = UserData.shareInstance().gender!
        age = UserData.shareInstance().age!
        height = UserData.shareInstance().height!
    }
}

// MARK: - 计算属性
extension ScaleResult {
    
    // 基础代谢
    var BMR: Float {
        if gender {
            return 10 * weight + 6.25 * Float(height) - 5 * Float(age) + 5
        }
        else {
            return 10 * weight + 6.25 * Float(height) - 5 * Float(age) - 161
        }
    }
    
    var bmi: Float {
        return weight / (Float(height)/100) / (Float(height)/100)
    }
    
    // 标准体重 = S
    var SW: Float {
        if gender {
            return 0.00452 * Float(height) * Float(height) - 0.55564 * Float(height) + 26.36570
        }
        else {
            return 0.00465 * Float(height) * Float(height) - 0.59980 * Float(height) + 29.99886
        }
    }
    
    // 去脂体重
    var LBM: Float {
        return (SW + 0.5684) / (1 - 0.0537)
    }
    
    // 脂肪控制量
    var fatControl: Float {
        if !gender {
            if fatWeight > weight * 0.28 {
                return weight * 0.23 - fatWeight
            }
            else if fatWeight < weight * 0.18 {
                return weight * 0.18 - fatWeight
            }
            else {
                return 0
            }
        }
        else {
            if fatWeight > weight * 0.2 {
                return weight * 0.15 - fatWeight
            }
            else if fatWeight < weight * 0.1 {
                return weight * 0.1 - fatWeight
            }
            else {
                return 0
            }
        }
    }
    
    // 标准肌肉
    var m_smm: Float {
        if gender {
            // 男
            return 0.00344 * Float(height) * Float(height) - 0.37678 * Float(height) + 14.40021
        }
        else {
            // 女
            return 0.00351 * Float(height) * Float(height) - 0.4661 * Float(height) + 23.04821
        }
    }
    
    // 肌肉控制量
    var muscleControl: Float {
        return muscleWeight < m_smm ? m_smm - muscleWeight : 0
    }
}

// MARK: - 评分计算
extension ScaleResult {
    
    var score: Float {
        
        var dtotal: Float = 0
        var m_fGradeFM: Float = 0
        var m_fGradeSLM: Float = 0
        var m_fGradePM: Float = 0
        var m_fGradeMM: Float = 0
        
        let pslm: Float = muscleWeight / m_smm
        let pfm: Float = fatPercentage
        let ppm: Float = proteinWeight / weight * 100
        let pmm: Float = boneWeight / weight * 100
        
        if gender {
            // 男
            if pfm < 10.0 {
                m_fGradeFM = pfm
                m_fGradeFM /= 10.0
                m_fGradeFM *= M_FM_GRADE1
            }
            else if pfm >= 10.0 && pfm <= 20.0 {
                if pfm == 15.0 {
                    m_fGradeFM = M_FM_GRADE0
                }
                else {
                    if pfm < 15.0 {
                        m_fGradeFM = pfm - 10.0
                    }
                    else {
                        m_fGradeFM = 20.0 - pfm
                    }
                    
                    m_fGradeFM /= 5.0
                    m_fGradeFM *= M_FM_GRADE2
                    m_fGradeFM += M_FM_GRADE1
                }
            }
            else if pfm > 20.0 && pfm <= 35.0 {
                m_fGradeFM = 35.0 - pfm
                m_fGradeFM /= 15.0
                m_fGradeFM *= M_FM_GRADE3
                m_fGradeFM += M_FM_GRADE3
            }
            else {
                m_fGradeFM = pfm - 35.0
                m_fGradeFM /= 35.0
                m_fGradeFM *= M_FM_GRADE3
                
                if m_fGradeFM >= M_FM_GRADE3 {
                    m_fGradeFM = 0
                }
                else {
                    m_fGradeFM = M_FM_GRADE3 - m_fGradeFM
                }
            }
            
            /* ----------------------------------------- */
            
            m_fGradeSLM = pslm / M_SLM_RATE
            m_fGradeSLM *= M_SLM_GRADE
            if m_fGradeSLM > 100.0 {
                m_fGradeSLM = 100.0
            }
            
            /* ----------------------------------------- */
            
            m_fGradePM = ppm / M_PM_RATE
            m_fGradePM *= M_PM_GRADE
            if m_fGradePM > 100.0 {
                m_fGradePM = 100.0
            }
            
            /* ----------------------------------------- */
            
            m_fGradeMM = pmm / M_BMM_RATE
            m_fGradeMM *= M_BMM_GRADE
            if m_fGradeMM > 100.0 {
                m_fGradeMM = 100.0
            }
        }
        else {
            // 女
            
            if pfm < 18.0 {
                m_fGradeFM = pfm
                m_fGradeFM /= 18.0
                m_fGradeFM *= F_FM_GRADE1
            }
            else if pfm > 18.0 && pfm < 28 {
                if pfm == 23.0 {
                    m_fGradeFM = F_FM_GRADE0
                }
                else {
                    if pfm < 23.0 {
                        m_fGradeFM = pfm - 18.0
                    }
                    else {
                        m_fGradeFM = 28.0 - pfm
                    }
                    
                    m_fGradeFM /= 5.0
                    m_fGradeFM *= F_FM_GRADE2
                    m_fGradeFM += F_FM_GRADE1
                }
            }
            else if pfm > 28.0 && pfm < 43.0 {
                m_fGradeFM = 43.0 - pfm
                m_fGradeFM /= 15.0
                m_fGradeFM *= F_FM_GRADE3
                m_fGradeFM += F_FM_GRADE3
            }
            else {
                m_fGradeFM = pfm - 43.0
                m_fGradeFM /= 43.0
                m_fGradeFM *= F_FM_GRADE3
                if m_fGradeFM > F_FM_GRADE3 {
                    m_fGradeFM = 0
                }
                else {
                    m_fGradeFM = F_FM_GRADE3 - m_fGradeFM
                }
            }
            
            /* ----------------------------------------- */
            m_fGradeSLM = pslm / F_SLM_RATE
            m_fGradeSLM *= F_SLM_GRADE
            if m_fGradeSLM > 100 {
                m_fGradeSLM = 100.0
            }
            
            /* ----------------------------------------- */
            m_fGradePM = ppm / F_PM_RATE
            m_fGradePM *= F_PM_GRADE
            if m_fGradePM > 100 {
                m_fGradePM = 100.0
            }
            
            /* ----------------------------------------- */
            
            m_fGradeMM = pmm / F_BMM_RATE
            m_fGradeMM *= F_BMM_GRADE
            if m_fGradeMM > 100 {
                m_fGradeMM = 100
            }
        }
        
        dtotal = 0.1 * m_fGradeSLM + 0.6 * m_fGradeFM + 0.2 * m_fGradePM + 0.1 * m_fGradeMM
        
        if dtotal > 100 {
            dtotal == 100
        }
        
        return  dtotal
    }
    
    // 计算身体年龄
    var bodyAge: Float {
        let score = self.score
        
        var result: Float = 0
        
        if score > 80 {
            result = Float(self.age) / (score / 80)
        }
        else if score < 75 {
            result = Float(self.age) / (score / 75)
        }
        else {
            result = Float(self.age)
            if result - Float(self.age) > 5 {
                result = Float(self.age) + 5
            }
            else if result - Float(self.age) < -5 {
                result = Float(self.age) - 5
            }
            else {
                result = Float(self.age)
            }
        }
        
        return result
    }
}

// MARK: - 等级判断
extension ScaleResult {
    
    enum WeightStatus {
        case Thin   // 瘦
        case Normal // 正常
        case LittleFat  // 轻度肥胖
        case MiddleFat  // 中度肥胖
        case HighFat   // 重度肥胖
        case VeryFat    // 极度肥胖
        
        init(fatPercentage: Float, gender: Bool) {
            if gender {
                if fatPercentage < 16 {
                    self = .Thin
                }
                else if fatPercentage < 20 {
                    self = .Normal
                }
                else if fatPercentage < 24 {
                    self = .LittleFat
                }
                else if fatPercentage < 28 {
                    self = .MiddleFat
                }
                else if fatPercentage < 30 {
                    self = .HighFat
                }
                else {
                    self = .VeryFat
                }
            }
            else {
                if fatPercentage < 18 {
                    self = .Thin
                }
                else if fatPercentage < 22 {
                    self = .Normal
                }
                else if fatPercentage < 26 {
                    self = .LittleFat
                }
                else if fatPercentage < 29 {
                    self = .MiddleFat
                }
                else if fatPercentage < 35 {
                    self = .HighFat
                }
                else {
                    self = .VeryFat
                }
            }
        }
        
        var description: String {
            switch self {
            case .Thin:
                return "过瘦"
            case .Normal:
                return "正常"
            case .LittleFat:
                return "轻度肥胖"
            case .MiddleFat:
                return "中度肥胖"
            case .HighFat:
                return "重度肥胖"
            case .VeryFat:
                return "极度肥胖"
            }
        }
    }
    
    enum ValueStatus {
        case Low    // 偏低
        case Normal // 正常
        case High   // 偏高
        
        init(value: Float, low: Float, high: Float) {
            if value > high {
                self = .High
            }
            else if value < low {
                self = .Low
            }
            else {
                self = .Normal
            }
        }
        
        var statusColor: UIColor {
            switch self {
            case .Low:
                return UIColor.brownColor()
            case .Normal:
                return UIColor.greenColor()
            case .High:
                return UIColor.redColor()
            }
        }
    }
    
    var waterWeightRange: (Float, Float) {
        return (0.54 * weight, 0.66 * weight)
    }
    var waterWeightStatus: ValueStatus {
        return ValueStatus(value: waterWeight, low: waterWeightRange.0, high: waterWeightRange.1)
    }
    
    var proteinWeightRange: (Float, Float) {
        return (0.1395 * weight, 0.1705 * weight)
    }
    var proteinWeightStatus: ValueStatus {
        return ValueStatus(value: proteinWeight, low: proteinWeightRange.0, high: proteinWeightRange.1)
    }
    
    var boneWeightRange: (Float, Float) {
        return (0.045 * weight, 0.055 * weight)
    }
    var boneWeightStatus: ValueStatus {
        return ValueStatus(value: boneWeight, low: boneWeightRange.0, high: boneWeightRange.1)
    }
    
    var weightRange: (Float, Float) {
        return (0.9 * SW, 1.1 * SW)
    }
    var weightStatus: ValueStatus {
        return ValueStatus(value: weight, low: weightRange.0, high: weightRange.1)
    }
    var weightStatusDescription: String {
        return WeightStatus(fatPercentage: fatPercentage, gender: gender).description
    }
    
    var fatWeightRange: (Float, Float) {
        if gender {
            return (0.1 * weight, 0.2 * weight)
        }
        else {
            return (0.18 * weight, 0.28 * weight)
        }
    }
    var fatWeightStatus: ValueStatus {
        return ValueStatus(value: fatWeight, low: fatWeightRange.0, high: fatWeightRange.1)
    }
    
    var muscleWeightRange: (Float, Float) {
        return (0.9 * m_smm, 1.1 * m_smm)
    }
    var muscleWeightStatus: ValueStatus {
        return ValueStatus(value: muscleWeight, low: muscleWeightRange.0, high: muscleWeightRange.1)
    }
    
    var boneMuscleLevel: ValueStatus {
        if gender {
            return ValueStatus(value: boneMuscleWeight, low: 0.75 * 0.9 * m_smm * 0.82, high: 0.75 * 1.1 * m_smm * 0.82)
        }
        else {
            return ValueStatus(value: boneMuscleWeight, low: 0.75 * 0.9 * m_smm * 0.77, high: 0.75 * 1.1 * m_smm * 0.77)
        }
    }
    
    var visceralFatContentRange: (Float, Float) {
        return (10, 5.5)
    }
    var visceralFatContentStatus: ValueStatus {
        
        /*内脏脂肪指数判定 0.5-5.5 		正常 5.5-10 		超标 10以上 		高*/
        let status = ValueStatus(value: visceralFatPercentage, low: visceralFatContentRange.0, high: visceralFatContentRange.1)
        if status == .Low {
            return .Normal
        }
        else if status == .Normal {
            return .Low
        }
        else {
            return .High
        }
    }
    
    var fatPercentageRange: (Float, Float) {
        if gender {
            return (10, 20)
        }
        else {
            return (18, 28)
        }
    }
    var fatPercentageStatus: ValueStatus {
        return ValueStatus(value: fatPercentage, low: fatPercentageRange.0, high: fatPercentageRange.1)
    }
    
    var BMIRange: (Float, Float) {
        return (18.5, 24)
    }
    var BMIStatus: ValueStatus {
        return ValueStatus(value: bmi, low: BMIRange.0, high: BMIRange.1)
    }
}

// MARK: - 体型
extension ScaleResult {
    
    // 体型
    enum Physique: Int {
        case HiddenFat = 1      // 隐性肥胖
        case LotOfFat       // 脂肪过多
        case Fat            // 肥胖
        case LittleMuscle   // 肌肉不足
        case Health          // 健康
        case LotOfMuscle    // 超重肌肉
        case Spare          // 消瘦
        case LittleFat      // 低脂肪
        case Athlete        // 运动员
        
        var imageName: String {
            switch self {
            case .HiddenFat:
                return "hiddenFat"
            case .LotOfFat:
                return "lotOfFat"
            case .Fat:
                return "fat"
            case .LittleMuscle:
                return "littleMuscle"
            case .Health:
                return "health"
            case .LotOfMuscle:
                return "lotOfMuscle"
            case .Spare:
                return "spare"
            case .LittleFat:
                return "littleFat"
            case .Athlete:
                return "athlete"
            }
        }
        
        var selectImageName: String {
            return "\(self.imageName)Selected"
        }
        
        var description: String {
            switch self {
            case .HiddenFat:
                return "隐形肥胖型"
            case .LotOfFat:
                return "脂肪过多型"
            case .Fat:
                return "肥胖型"
            case .LittleMuscle:
                return "肌肉不足型"
            case .Health:
                return "健康匀称型"
            case .LotOfMuscle:
                return "超重肌肉型"
            case .Spare:
                return "消瘦型"
            case .LittleFat:
                return "低脂肪型"
            case .Athlete:
                return "运动员型"
            }
        }
        
        init (gender: Bool, fatPercentage: Float, BMI: Float) {
            let lowFatPercentage: Float = gender ? 10 : 20
            let highFatPercentage: Float = gender ? 20 : 30
            
            let lowBMI: Float = 18.5
            let highBMI: Float = 25
            
            if fatPercentage < lowFatPercentage {
                if BMI < lowBMI {
                    self = .Spare
                }
                else if BMI > highBMI {
                    self = .Athlete
                }
                else {
                    self = .LittleFat
                }
            }
            else if fatPercentage > highFatPercentage {
                if BMI < lowBMI {
                    self = .HiddenFat
                }
                else if BMI > highBMI {
                    self = .Fat
                }
                else {
                    self = .LotOfFat
                }
            }
            else {
                if BMI < lowBMI {
                    self = .LittleMuscle
                }
                else if BMI > highBMI {
                    self = .LotOfMuscle
                }
                else {
                    self = .Health
                }
            }
        }
    }
    
    // 体型
    var physique: Physique {
        return Physique(gender: gender, fatPercentage: fatPercentage, BMI: bmi)
    }
}


// MARK: - 宏定义
extension ScaleResult {
    
    var M_SLM_RATE: Float {
        // 设定的男性肌肉百分比的最高值
        return 1.19
    }
    
    var M_SLM_GRADE: Float {
        // 设定的男性肌肉的最高评分
        return 90.0
    }
    
    var M_FM_GRADE0: Float {
        // 设定的男性脂肪量的最高评分
        return 90.0
    }
    
    var M_FM_GRADE1: Float {
        // 设定的男性脂肪量第一段的最低评分
        return 73
    }
    
    var M_FM_GRADE2: Float {
        // 男性脂肪量第一段到最高分之间的差值
        return 30
    }
    
    var M_FM_GRADE3: Float {
        // 男性第三段和第四段的基础分值（70分的一半。这两端可以分成不同的区间）
        return 40
    }
    
    var M_PM_RATE: Float {
        // 设定的男性蛋白质体重百分比的最高值
        return 18.1
    }
    
    var M_PM_GRADE: Float {
        // 设定的男性蛋白质的最高评分
        return 90
    }
    
    var M_BMM_RATE: Float {
        // 设定的男性骨质体重百分比的最高值
        return 5.9
    }
    
    var M_BMM_GRADE: Float {
        // 设定的男性骨质的最高评分
        return 90
    }
    
    var F_SLM_RATE: Float {
        // 设定的女性肌肉百分比的最高值
        return 1.15
    }
    
    var F_SLM_GRADE: Float {
        // 设定的女性肌肉的最高评分
        return 90
    }
    
    var F_FM_GRADE0: Float {
        // 设定的女性脂肪量的最高评分
        return 90
    }
    
    var F_FM_GRADE1: Float {
        // 设定的女性脂肪量第一段的最低评分
        return 69
    }
    
    var F_FM_GRADE2: Float {
        // 女性脂肪量第一段到最高分之间的差值
        return 20
    }
    
    var F_FM_GRADE3: Float {
        // 女性第三段和第四段的基础分值（70分的一半。这两端可以分成不同的区间）
        return 35
    }
    
    var F_PM_RATE: Float {
        // 设定的女性蛋白质体重百分比的最高值
        return 15.9
    }
    
    var F_PM_GRADE: Float {
        // 设定的女性蛋白质的最高评分
        return 90
    }
    
    var F_BMM_RATE: Float {
        // 设定的女性骨质体重百分比的最高值
        return 5.5
    }
    
    var F_BMM_GRADE: Float {
        // 设定的女性骨质的最高评分
        return 90
    }
}