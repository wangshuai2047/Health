//
//  ScaleResultExtension.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

func ScaleResultProtocolCreate(_ info: [String : AnyObject], gender: Bool, age: UInt8, height: UInt8) -> ScaleResultProtocol {
    
    if let deviceType = (info["deviceType"] as? NSNumber) {
        if deviceType == 0 {
            return MyBodyResult(info: info, gender: gender, age: age, height: height)
        }
        else if deviceType == 1 {
            return MyBodyMiniAndPlusResult(info: info, gender: gender, age: age, height: height)
        }
        else {
            return MyBodyMiniAndPlusResult(info: info, gender: gender, age: age, height: height)
        }
    }
    else {
        if let HAI = info["hepaticAdiposeInfiltration"] as? NSNumber {
            
            if HAI.int16Value == 1 || HAI.int16Value == 2{
                return MyBodyMiniAndPlusResult(info: info, gender: gender, age: age, height: height)
            }
        }
        return MyBodyMiniAndPlusResult(info: info, gender: gender, age: age, height: height)
    }
}


extension ScaleResultProtocol {
    
    func uploadInfo(_ timestamp: Int) -> [String: AnyObject] {
        
        var uploadInfo : [String: AnyObject] = [
            
            "userId" : userId as AnyObject,
            "boneWeight" : boneWeight as AnyObject,
            "boneMuscleWeight" : boneMuscleWeight as AnyObject,
            "fatPercentage" : fatPercentage / 100 as AnyObject,
            "fatWeight" : fatWeight as AnyObject,
            "muscleWeight" : muscleWeight as AnyObject,
            "proteinWeight" : proteinWeight as AnyObject,
            "visceralFatPercentage" : visceralFatPercentage as AnyObject,
            "waterPercentage" : waterPercentage as AnyObject,
            "waterWeight" : waterWeight as AnyObject,
            "weight" : weight as AnyObject,
            "timeStamp" : timestamp as AnyObject
        ]
        
        if let _ = self as? MyBodyResult {
            uploadInfo["deviceType"] = 0 as AnyObject
        }
        if let _ = self as? MyBodyMiniAndPlusResult {
            uploadInfo["deviceType"] = 1 as AnyObject
        }
        
        uploadInfo["bmi"] = BMI as AnyObject
        uploadInfo["bmiMax"] = BMIRange.1 as AnyObject
        uploadInfo["bmiMin"] = BMIRange.0 as AnyObject
        uploadInfo["bmr"] = BMR as AnyObject
        uploadInfo["bodyAge"] = bodyAge as AnyObject
        uploadInfo["boneMuscleWeightMax"] = boneMuscleRange.1 as AnyObject
        uploadInfo["boneMuscleWeightMin"] = boneMuscleRange.0 as AnyObject
        uploadInfo["boneWeightMax"] = boneWeightRange.1 as AnyObject
        uploadInfo["boneWeightMin"] = boneWeightRange.0 as AnyObject
        uploadInfo["fatControl"] = fatControl as AnyObject
        uploadInfo["fatFreeBodyWeight"] = fatFreeBodyWeight as AnyObject
        uploadInfo["fatFreeBodyWeightMax"] = fatFreeBodyWeightRange.1 as AnyObject
        uploadInfo["fatFreeBodyWeightMin"] = fatFreeBodyWeightRange.0 as AnyObject
        uploadInfo["fatPercentageMax"] = fatPercentageRange.1 as AnyObject
        uploadInfo["fatPercentageMin"] = fatPercentageRange.0 as AnyObject
        uploadInfo["fatWeightMax"] = fatWeightRange.1 as AnyObject
        uploadInfo["fatWeightMin"] = fatWeightRange.0 as AnyObject
        uploadInfo["goalWeight"] = goalWeight as AnyObject
        if hepaticAdiposeInfiltration == nil {
            uploadInfo["hepaticAdiposeInfiltration"] = 0 as AnyObject
        }
        else {
            uploadInfo["hepaticAdiposeInfiltration"] = (hepaticAdiposeInfiltration! ? 1 : 0) as AnyObject
        }
        uploadInfo["leftLowerExtremityBone"] = leftLowerExtremityBone as AnyObject
        uploadInfo["leftLowerExtremityFat"] = leftLowerExtremityFat as AnyObject
        uploadInfo["leftLowerExtremityMuscle"] = leftLowerExtremityMuscle as AnyObject
        uploadInfo["leftUpperExtremityBone"] = leftUpperExtremityBone as AnyObject
        uploadInfo["leftUpperExtremityFat"] = leftUpperExtremityFat as AnyObject
        uploadInfo["leftUpperExtremityMuscle"] = leftUpperExtremityMuscle as AnyObject
        uploadInfo["muscleControl"] = muscleControl as AnyObject
        uploadInfo["m_smm"] = m_smm as AnyObject
        uploadInfo["muscleWeightMax"] = muscleWeightRange.1 as AnyObject
        uploadInfo["muscleWeightMin"] = muscleWeightRange.0 as AnyObject
        uploadInfo["proteinWeightMax"] = proteinWeightRange.1 as AnyObject
        uploadInfo["proteinWeightMin"] = proteinWeightRange.0 as AnyObject
        uploadInfo["rightLowerExtremityBone"] = rightLowerExtremityBone as AnyObject
        uploadInfo["rightLowerExtremityFat"] = rightLowerExtremityFat as AnyObject
        uploadInfo["rightLowerExtremityMuscle"] = rightLowerExtremityMuscle as AnyObject
        uploadInfo["rightUpperExtremityBone"] = rightUpperExtremityBone as AnyObject
        uploadInfo["rightUpperExtremityFat"] = rightUpperExtremityFat as AnyObject
        uploadInfo["rightUpperExtremityMuscle"] = rightUpperExtremityMuscle as AnyObject
        uploadInfo["score"] = score as AnyObject
        
        uploadInfo["sw"] = SW as AnyObject
        uploadInfo["swMax"] = SWRange.1 as AnyObject
        uploadInfo["swMin"] = SWRange.0 as AnyObject
        uploadInfo["trunkLimbBone"] = trunkLimbBone as AnyObject
        uploadInfo["trunkLimbFat"] = trunkLimbFat as AnyObject
        uploadInfo["trunkLimbMuscle"] = trunkLimbMuscle as AnyObject
        uploadInfo["waterWeightMax"] = waterWeightRange.1 as AnyObject
        uploadInfo["waterWeightMin"] = waterWeightRange.0 as AnyObject
        uploadInfo["weightControl"] = weightControl as AnyObject
        uploadInfo["whr"] = WHR as AnyObject
        uploadInfo["whrMax"] = WHRRange.1 as AnyObject
        uploadInfo["whrMin"] = WHRRange.0 as AnyObject
        uploadInfo["externalMoisture"] = externalMoisture as AnyObject
        uploadInfo["internalMoisture"] = internalMoisture as AnyObject
        uploadInfo["edemaFactor"] = edemaFactor as AnyObject
        uploadInfo["obesity"] = obesity as AnyObject
        
        return uploadInfo
    }
}

// 创建结果
extension ScaleResultProtocol {
    
    
}

// MARK: - 计算属性
extension ScaleResultProtocol {
    
    // 体重范围
    var weightRange: (Float, Float) {
        get {
            return (0.9 * SW, 1.1 * SW)
        }
        set {
            
        }
    }
    
    // 内脏脂肪范围
    var visceralFatContentRange: (Float, Float) {
        get {
            return (10, 14)
        }
        set {
            
        }
    }
    
    // 去脂体重
    var LBM: Float {
        get {
            return weight - fatWeight
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
    
    // 脂肪肝风险度
    var fattyLiverRisk: Float {
        if gender {
            // 男
            if fatWeight < 10 {
                return 0
            }
            else if fatWeight < 11.9 {
                return 10
            }
            else if fatWeight < 13.6 {
                return 20
            }
            else if fatWeight < 14.9 {
                return 30
            }
            else if fatWeight < 16.55 {
                return 40
            }
            else if fatWeight < 16.80 {
                return 50
            }
            else if fatWeight < 17.70 {
                return 60
            }
            else if fatWeight < 19.30 {
                return 70
            }
            else if fatWeight < 22.00 {
                return 80
            }
            else {
                return 90
            }
        }
        else {
            // 女
            if fatWeight < 10.6 {
                return 0
            }
            else if fatWeight < 13.00 {
                return 10
            }
            else if fatWeight < 14.70 {
                return 20
            }
            else if fatWeight < 16.10 {
                return 30
            }
            else if fatWeight < 17.45 {
                return 40
            }
            else if fatWeight < 18.40 {
                return 50
            }
            else if fatWeight < 20.10 {
                return 60
            }
            else if fatWeight < 22.00 {
                return 70
            }
            else if fatWeight < 24.90 {
                return 80
            }
            else {
                return 90
            }
        }
    }
    
    var fattyLiverRange: (Float, Float) {
        return (50, 80)
    }
}

// MARK: - 等级判断
extension ScaleResultProtocol {
    
    var fattyLiverStatus: ValueStatus {
        
        if hepaticAdiposeInfiltration == nil {
            return .high
        }
        
        if fattyLiverRisk < fattyLiverRange.0 {
            return ValueStatus.normal
        }
        else if fattyLiverRisk < fattyLiverRange.1 {
            return ValueStatus.low
        }
        else {
            return ValueStatus.high
        }
    }
    
    var waterWeightStatus: ValueStatus {
        return ValueStatus(value: waterWeight, low: waterWeightRange.0, high: waterWeightRange.1)
    }
    
    var proteinWeightStatus: ValueStatus {
        return ValueStatus(value: proteinWeight, low: proteinWeightRange.0, high: proteinWeightRange.1)
    }
    
    var boneWeightStatus: ValueStatus {
        return ValueStatus(value: boneWeight, low: boneWeightRange.0, high: boneWeightRange.1)
    }
    
    var weightStatus: ValueStatus {
        return ValueStatus(value: weight, low: weightRange.0, high: weightRange.1)
    }
    var weightStatusDescription: String {
        return WeightStatus(fatPercentage: fatPercentage, gender: gender).description
    }
    
    var fatWeightStatus: ValueStatus {
        return ValueStatus(value: fatWeight, low: fatWeightRange.0, high: fatWeightRange.1)
    }
    
    var muscleWeightStatus: ValueStatus {
        return ValueStatus(value: muscleWeight, low: muscleWeightRange.0, high: muscleWeightRange.1)
    }
    
    var boneMuscleLevel: ValueStatus {
        
        let status: ValueStatus;
        if gender {
            status = ValueStatus(value: boneMuscleWeight, low: 0.75 * 0.9 * m_smm * 0.82, high: 0.75 * 1.1 * m_smm * 0.82)
        }
        else {
            status = ValueStatus(value: boneMuscleWeight, low: 0.75 * 0.9 * m_smm * 0.77, high: 0.75 * 1.1 * m_smm * 0.77)
        }
        
        // 骨骼肌 如果低则提示警告，高则是正常的。
        if status == .low {
            return .low
        }
        else {
            return .normal
        }
    }
    
    var visceralFatContentStatus: ValueStatus {
        
        /*内脏脂肪指数判定 0-10 		正常 10-14 		超标 14以上 		高*/
        let status = ValueStatus(value: visceralFatPercentage, low: visceralFatContentRange.0, high: visceralFatContentRange.1)
        if status == .low {
            return .normal
        }
        else if status == .normal {
            return .low
        }
        else {
            return .high
        }
    }
    
    var fatPercentageStatus: ValueStatus {
        return ValueStatus(value: fatPercentage, low: fatPercentageRange.0 * 100, high: fatPercentageRange.1 * 100)
    }
    
    var BMIStatus: ValueStatus {
        return ValueStatus(value: BMI, low: BMIRange.0, high: BMIRange.1)
    }
}

// MARK: - 评分计算
extension ScaleResultProtocol {
    
}

// MARK: - 体型
extension ScaleResultProtocol {
    // 已改为子类实现
//    // 体型
//    var physique: Physique {
//        return Physique(gender: gender, fatPercentage: fatPercentage, BMI: BMI)
//    }
}



