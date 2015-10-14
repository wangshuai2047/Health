//
//  MyBodyResult.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

struct MyBodyResult: ScaleResultProtocol {
    
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
    
    
    
    
    
    
    
    
//    // 健康评分
//    var score: Float
//    
//    // 计算身体年龄
//    var bodyAge: Float
//    
//    
//    var waterWeightRange: (Float, Float)
//    var proteinWeightRange: (Float, Float)
//    var boneWeightRange: (Float, Float)
//    var weightRange: (Float, Float)
//    var fatWeightRange: (Float, Float)
//    var muscleWeightRange: (Float, Float)
//    var visceralFatContentRange: (Float, Float)
//    var fatPercentageRange: (Float, Float)
//    var BMIRange: (Float, Float)
//    
//    // 基础代谢
//    var BMR: Float
//    
//    // 体质指数
//    var BMI: Float
//    
//    // 标准体重 = S
//    var SW: Float
//    
//    // 去脂体重
//    var LBM: Float
//    
//    // 脂肪控制量
//    var fatControl: Float
//    
//    // 标准肌肉
//    var m_smm: Float
//    
//    // 肌肉控制量
//    var muscleControl: Float
//    
//    // 标准体脂率
//    var standardFatPercentage: Float
    
    
    
    
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
    
    static func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol {
        
        /*
        从四点极称中，我们只需要三项数据：水分率、内脏脂肪率和体重
        水分率为a%，体脂率为p%，体重为W，身高为h，年龄为age
        身体评分和身体年龄的公式已经给
        
        体脂率（男）       p% =（1-((a%*100)/73.81)+(0.6/W)）*100-1
        女               p% =（1-((a%*100)/73.81)+(0.6/W)）*100+1
        
        脂肪重 F=W*p%
        水分重 a=W*a%
        肌肉重 S=a/0.78
        蛋白质重 M=S-a
        骨重 B=W-F-S
        */
        
        let gender = UserData.shareInstance().gender!
        
        // 体脂率
        var fatPercentage = (1 - ((waterContent)/73.81) + (0.6 / weight)) * 100 - 1 // 男
        if gender == false {
            fatPercentage += 2 // 女
        }
        
        // 脂肪重
        let fatWeight = weight * fatPercentage / 100
        // 水分重
        let waterWeight = weight * waterContent / 100
        // 肌肉重
        let muscleWeight = waterWeight / 0.78
        // 蛋白质重
        let proteinWeight =  muscleWeight - waterWeight
        // 骨重
        let boneWeight = weight - fatWeight - muscleWeight
        // 骨骼肌重
        let boneMuscleWeight = muscleWeight * 0.7135
        
        let result = MyBodyResult(userId: userId, gender: gender, age: age, height: height, weight: weight, waterContent: waterContent, visceralFatContent: visceralFatContent, fatPercentage: fatPercentage, fatWeight: fatWeight, waterWeight: waterWeight, muscleWeight: muscleWeight, proteinWeight: proteinWeight, boneWeight: boneWeight, boneMuscleWeight: boneMuscleWeight)
        
        return result
    }
}

// MARK: - 计算属性
extension MyBodyResult {
    // 基础代谢
    var BMR: Float {
        get {
            if gender {
                return 10 * weight + 6.25 * Float(height) - 5 * Float(age) + 5
            }
            else {
                return 10 * weight + 6.25 * Float(height) - 5 * Float(age) - 161
            }
        }
        set {
            
        }
    }
    
    // 体质指数
    var BMI: Float {
        return weight / (Float(height)/100) / (Float(height)/100)
    }
    
    // 标准体重 = S
    var SW: Float {
        get {
            if gender {
                return 0.00452 * Float(height) * Float(height) - 0.55564 * Float(height) + 26.36570
            }
            else {
                return 0.00465 * Float(height) * Float(height) - 0.59980 * Float(height) + 29.99886
            }
        }
        set {
            
        }
    }
    
    // 去脂体重
    var LBM: Float {
        get {
            return (SW + 0.5684) / (1 - 0.0537)
        }
        set {
            
        }
    }
    
    // 脂肪控制量
    var fatControl: Float {
        get {
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
        set {
            
        }
    }
    
    // 标准肌肉
    var m_smm: Float {
        get {
            if gender {
                // 男
                return 0.00344 * Float(height) * Float(height) - 0.37678 * Float(height) + 14.40021
            }
            else {
                // 女
                return 0.00351 * Float(height) * Float(height) - 0.4661 * Float(height) + 23.04821
            }
        }
        set {
            
        }
    }
    
    // 肌肉控制量
    var muscleControl: Float {
        get {
            return muscleWeight < m_smm ? m_smm - muscleWeight : 0
        }
        set {
            
        }
    }
    
    // 标准体脂率
    var standardFatPercentage: Float {
        get {
            return gender ? 15 : 25
        }
        set {
            
        }
    }
}

// MARK: - 等级判断
extension MyBodyResult {
    
    var waterWeightRange: (Float, Float) {
        get {
            return (0.54 * weight, 0.66 * weight)
        }
        set {
            
        }
    }
    
    var proteinWeightRange: (Float, Float) {
        get {
            return (0.1395 * weight, 0.1705 * weight)
        }
        set {
            
        }
    }
    
    var boneWeightRange: (Float, Float) {
        get {
            return (0.045 * weight, 0.055 * weight)
        }
        set {
            
        }
    }
    
    var weightRange: (Float, Float) {
        get {
            return (0.9 * SW, 1.1 * SW)
        }
        set {
            
        }
    }
    
    var fatWeightRange: (Float, Float) {
        get {
            if gender {
                return (0.1 * weight, 0.2 * weight)
            }
            else {
                return (0.18 * weight, 0.28 * weight)
            }
        }
        set {
            
        }
    }
    
    var muscleWeightRange: (Float, Float) {
        get {
            return (0.9 * m_smm, 1.1 * m_smm)
        }
        set {
            
        }
    }
    
    
    var visceralFatContentRange: (Float, Float) {
        get {
            return (10, 5.5)
        }
        set {
            
        }
    }
    
    var fatPercentageRange: (Float, Float) {
        get {
            if gender {
                return (10, 20)
            }
            else {
                return (18, 28)
            }
        }
        set {
            
        }
    }
    
    var BMIRange: (Float, Float) {
        get {
            return (18.5, 24)
        }
        set {
            
        }
    }
}

// MARK: - 评分计算
extension MyBodyResult {
    
    var score: Float {
        get {
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
        set {
            
        }
    }
    
    // 计算身体年龄
    var bodyAge: Float {
        get {
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
        set {
            
        }
    }
}

// MARK: - 宏定义
extension MyBodyResult {
    
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

extension MyBodyResult {
    
}

extension MyBodyResult {
    
    init(info: [String: AnyObject]) {
        
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