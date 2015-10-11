//
//  ScaleResultExtension.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

extension ScaleResultProtocol {
    
    func uploadInfo(timestamp: Int) -> [String: AnyObject] {
        
        let uploadInfo : [String: AnyObject] = [
            
            "userId" : userId,
            "boneWeight" : boneWeight,
            "boneMuscleWeight" : boneMuscleWeight,
            "fatPercentage" : fatPercentage,
            "fatWeight" : fatWeight,
            "muscleWeight" : muscleWeight,
            "proteinWeight" : proteinWeight,
            "visceralFatPercentage" : visceralFatPercentage,
            "waterPercentage" : waterPercentage,
            "waterWeight" : waterWeight,
            "weight" : weight,
            "timestamp" : timestamp
        ]
        
        return uploadInfo
    }
}

// MARK: - 计算属性
extension ScaleResultProtocol {
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
    
    // 标准体脂率
    var standardFatPercentage: Float {
        return gender ? 15 : 25
    }
    // 每日需消耗卡路里
    var dayNeedCalorie: Float {
        if gender {
            // 男
            if weight <= 60 {
                return 2030
            }
            else if weight <= 70 {
                return 2030
            }
            else if weight <= 80 {
                return 2370
            }
            else if weight <= 90 {
                return 2710
            }
            else {
                return 3050
            }
        }
        else {
            // 女
            if weight <= 50 {
                return 1520
            }
            else if weight <= 55 {
                return 1520
            }
            else if weight <= 60 {
                return 1680
            }
            else if weight <= 65 {
                return 1830
            }
            else {
                return 1980
            }
        }
    }
}

// MARK: - 评分计算
extension ScaleResultProtocol {
    
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
extension ScaleResultProtocol {
    
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
extension ScaleResultProtocol {
    // 体型
    var physique: Physique {
        return Physique(gender: gender, fatPercentage: fatPercentage, BMI: bmi)
    }
}


// MARK: - 宏定义
extension ScaleResultProtocol {
    
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
