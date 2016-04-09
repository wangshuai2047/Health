//
//  EvaluationDetailExtendViewModel.swift
//  Health
//
//  Created by Yalin on 15/10/27.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation
/*
*/

enum EvaluationDetailExtendType {
    case fattyLiver         // 脂肪肝
    case weight
    case fatPercentage
    case fat
    case muscle
    case boneMuscle
    case water
    case protein
    case bone
    case visceralFat
    case bmi
    case BMR                // 基础代谢
    case bodyAge            // 身体年龄
    case fatLevel           // 肥胖等级
    case standardWeight     // 标准体重
    case weightControl      // 体重控制量
    case noFatWeight        // 去脂体重
    case fatControl         // 脂肪控制量
    case muscleControl      // 肌肉控制量
    
    var headIcon: String {
        switch self {
        case .fattyLiver:
            return "fattyLiverIcon"
        case .weight:
            return "weightIcon"
        case .fatPercentage:
            return "fatIcon"
        case .fat:
            return "fatIcon"
        case .muscle:
            return "muscleIcon"
        case .boneMuscle:
            return "muscleIcon"
        case .water:
            return "waterIcon"
        case .protein:
            return "proteinIcon"
        case .bone:
            return "boneIcon"
        case .visceralFat:
            return "visceralFatIcon"
        case .bmi:
            return "BMI"
        case .BMR:
            return "BMRIcon"
        case .bodyAge:
            return "BMI"
        case .fatLevel:
            return "BMI"
        case .standardWeight:
            return "BMI"
        case .weightControl:
            return "BMI"
        case .noFatWeight:
            return "BMI"
        case .fatControl:
            return "BMI"
        case .muscleControl:
            return "BMI"
        }
    }
    
    var title: String {
        switch self {
        case .fattyLiver:
            return "脂肪肝风险度"
        case .weight:
            return "体重"
        case .fatPercentage:
            return "体脂率"
        case .fat:
            return "脂肪量"
        case .muscle:
            return "肌肉"
        case .boneMuscle:
            return "骨骼肌"
        case .water:
            return "水分"
        case .protein:
            return "蛋白质"
        case .bone:
            return "骨量"
        case .visceralFat:
            return "内脏脂肪"
        case .bmi:
            return "BMI"
        case .BMR:
            return "基础代谢"
        case .bodyAge:
            return "身体年龄"
        case .fatLevel:
            return "肥胖等级"
        case .standardWeight:
            return "标准体重"
        case .weightControl:
            return "体重控制量"
        case .noFatWeight:
            return "去酯体重"
        case .fatControl:
            return "脂肪控制量"
        case .muscleControl:
            return "肌肉控制量"
        }
    }
    
    func unit(data: ScaleResultProtocol) -> String {
        switch self {
        case .fattyLiver:
            if let _ = data.hepaticAdiposeInfiltration {
                return "%"
            }
            return ""
        case .weight:
            return "kg"
        case .fatPercentage:
            return "%"
        case .fat:
            return "kg"
        case .muscle:
            return "kg"
        case .boneMuscle:
            return "kg"
        case .water:
            return "kg"
        case .protein:
            return "kg"
        case .bone:
            return "kg"
        case .visceralFat:
            return ""
        case .bmi:
            return ""
        case .BMR:
            return "kcal"
        case .bodyAge:
            return "岁"
        case .fatLevel:
            return ""
        case .standardWeight:
            return "kg"
        case .weightControl:
            return "kg"
        case .noFatWeight:
            return "kg"
        case .fatControl:
            return "kg"
        case .muscleControl:
            return "kg"
        }
    }
    
    var levelTitle: (String, String, String) {
        switch self {
        case .fattyLiver:
            return ("低度风险", "中度风险", "高度风险")
        case .visceralFat:
            return ("正常", "超标", "危险")
        default:
            return ("偏低", "正常", "偏高")
        }
    }
    
    var markBgImageName: String {
        switch self {
        case .fattyLiver:
            return "markbg2"
        case .visceralFat:
            return "markbg2"
        default:
            return "markBg"
        }
    }
    
    func levelDescription(data: ScaleResultProtocol) -> (String, String, String) {
        switch self {
        case .fattyLiver:
            return ("脂肪肝风险度：\(data.fattyLiverRisk)% 中度风险", "脂肪肝风险度：\(data.fattyLiverRisk)% 低度风险", "脂肪肝风险度：\(data.fattyLiverRisk)% 高度风险")
        case .weight:
            return ("您的体重偏低，需要注意。", "您的体重正常，请保持。", "您已经超重，请注意控制体重。")
        case .fatPercentage:
            return ("您体内的脂肪偏低，需要注意。", "您的体脂肪含量正常，请保持。", "您的脂肪含量超标，需要减脂。")
        case .fat:
            return ("您体内的脂肪偏低，需要注意。", "您的体脂肪含量正常，请保持。", "您的脂肪含量超标，需要减脂。")
        case .muscle:
            return ("您的肌肉含量偏低，建议适当增肌。", "您的肌肉含量正常，请保持。", "您的肌肉发达，请保持。")
        case .boneMuscle:
            return ("您的骨骼肌含量偏低，建议适当增肌。", "您的骨骼肌含量正常，请保持。", "您的骨骼肌发达，请保持。")
        case .water:
            return ("您体内水分偏低，注意多饮水。减低体脂肪含量有助于提高体内水分比例。", "您体内水分含量正常，请保持。", "您体内水分含量过高，请检查水肿系数。")
        case .protein:
            return ("您缺乏蛋白质，请增加高蛋白质食物摄入。提升肌肉量也有助于增加体内蛋白含量。", "您体内蛋白质含量正常，请保持。", "您的蛋白质含量较高，有可能是肌肉发达，对健康并无不良影响。")
        case .bone:
            return ("您的骨质含量偏低，可能是骨质疏松，请注意补充钙质，多运动。", "您的骨质含量正常，请保持。", "您的骨质含量较高，对健康并无不良影响，无需干预。")
        case .visceralFat:
            return ("您的内脏脂肪超标，容易患慢性疾病，请注意减脂。", "您的内脏脂肪正常，请保持。", "您的内脏脂肪较高，有较高的心脑血管疾病风险，请注意减脂。")
        case .bmi:
            return ("您的体型偏瘦，请适当增肌。", "您的体型正常，请保持。", "您已超重，请注意减重。")
        case .BMR:
            return ("", "", "")
        case .bodyAge:
            return ("", "", "")
        case .fatLevel:
            return ("", "", "")
        case .standardWeight:
            return ("", "", "")
        case .weightControl:
            return ("", "", "")
        case .noFatWeight:
            return ("", "", "")
        case .fatControl:
            return ("", "", "")
        case .muscleControl:
            return ("", "", "")
        }
    }
    
    func canExtend(data: ScaleResultProtocol) -> Bool {
        switch self {
        case .fattyLiver:
            if let _ = data.hepaticAdiposeInfiltration {
                return true
            }
            return false
        case .weight:
            return true
        case .fatPercentage:
            return true
        case .fat:
            return true
        case .muscle:
            return true
        case .boneMuscle:
            return true
        case .water:
            return true
        case .protein:
            return true
        case .bone:
            return true
        case .visceralFat:
            return true
        case .bmi:
            return true
        case .BMR:
            return false
        case .bodyAge:
            return false
        case .fatLevel:
            return false
        case .standardWeight:
            return false
        case .weightControl:
            return false
        case .noFatWeight:
            return false
        case .fatControl:
            return false
        case .muscleControl:
            return false
        }
    }
    
    func fatLevelShowString(fatPercentage: Float, gender: Bool) -> String {
        /*
         男：
         16以下 较轻
         16=<   <20 正常
         20=<   <24 轻度肥胖
         24=<   <28 中度肥胖
         28=<   <30 重度肥胖
         >=30        极度肥胖
         
         女：
         18以下 较轻
         18=<   <22 正常
         22=<   <26 轻度肥胖
         26=<   <29 中度肥胖
         29=<   <35 重度肥胖
         >=35        极度肥胖
         */
        
        if gender {
            // 男
            if fatPercentage < 16 {
                return "较轻"
            }
            else if fatPercentage < 20 {
                return "正常"
            }
            else if fatPercentage < 24 {
                return "轻度肥胖"
            }
            else if fatPercentage < 28 {
                return "中度肥胖"
            }
            else if fatPercentage < 30 {
                return "重度肥胖"
            }
            else {
                return "极度肥胖"
            }
        }
        else {
            // 女
            if fatPercentage < 18 {
                return "较轻"
            }
            else if fatPercentage < 22 {
                return "正常"
            }
            else if fatPercentage < 26 {
                return "轻度肥胖"
            }
            else if fatPercentage < 29 {
                return "中度肥胖"
            }
            else if fatPercentage < 35 {
                return "重度肥胖"
            }
            else {
                return "极度肥胖"
            }
        }
    }
    
    func value(data: ScaleResultProtocol) -> String {
        switch self {
        case .fattyLiver:
            if let _ = data.hepaticAdiposeInfiltration {
                return String(format: "%.0f", data.fattyLiverRisk)
            }
            return "此秤不支持"
        case .weight:
            return String(format: "%.1f", data.weight)
        case .fatPercentage:
            return String(format: "%.1f", data.fatPercentage)
        case .fat:
            return String(format: "%.1f", data.fatWeight)
        case .muscle:
            return String(format: "%.1f", data.muscleWeight)
        case .boneMuscle:
            return String(format: "%.1f", data.boneMuscleWeight)
        case .water:
            return String(format: "%.1f", data.waterWeight)
        case .protein:
            return String(format: "%.1f", data.proteinWeight)
        case .bone:
            return String(format: "%.1f", data.boneWeight)
        case .visceralFat:
            return String(format: "%.1f", data.visceralFatPercentage)
        case .bmi:
            return String(format: "%.1f", data.BMI)
        case .BMR:
            return String(format: "%.0f", data.BMR)
        case .bodyAge:
            return String(format: "%.0f", data.bodyAge)
        case .fatLevel:
            return fatLevelShowString(data.fatPercentage, gender: data.gender)
        case .standardWeight:
            return String(format: "%.0f", data.SW)
        case .weightControl:
            return String(format: "%.0f", data.weight - data.SW)
        case .noFatWeight:
            return String(format: "%.0f", data.LBM)
        case .fatControl:
            return String(format: "%.0f", data.fatControl)
        case .muscleControl:
            return String(format: "%.0f", data.muscleControl)
        }
    }
    
    
    
    func status(data: ScaleResultProtocol) -> ValueStatus {
        switch self {
        case .fattyLiver:
            return data.fattyLiverStatus
        case .weight:
            return data.weightStatus
        case .fatPercentage:
            return data.fatPercentageStatus
        case .fat:
            return data.fatWeightStatus
        case .muscle:
            return data.muscleWeightStatus
        case .boneMuscle:
            return data.boneMuscleLevel
        case .water:
            return data.waterWeightStatus
        case .protein:
            return data.proteinWeightStatus
        case .bone:
            return data.boneWeightStatus
        case .visceralFat:
            return data.visceralFatContentStatus
        case .bmi:
            return data.BMIStatus
        case .BMR:
            return ValueStatus.Normal
        case .bodyAge:
            return ValueStatus.Normal
        case .fatLevel:
            return ValueStatus.Normal
        case .standardWeight:
            return ValueStatus.Normal
        case .weightControl:
            return ValueStatus.Normal
        case .noFatWeight:
            return ValueStatus.Normal
        case .fatControl:
            return ValueStatus.Normal
        case .muscleControl:
            return ValueStatus.Normal
        }
    }
    
    func range(data: ScaleResultProtocol) -> (Float, Float) {
        switch self {
        case .weight:
            return data.SWRange
        case .fatPercentage:
            return (data.fatPercentageRange.0 * 100, data.fatPercentageRange.1 * 100)
        case .fat:
            return data.fatWeightRange
        case .muscle:
            return data.muscleWeightRange
        case .boneMuscle:
            return data.boneMuscleRange
        case .water:
            return data.waterWeightRange
        case .protein:
            return data.proteinWeightRange
        case .bone:
            return data.boneWeightRange
        case .visceralFat:
            return data.visceralFatContentRange
        case .bmi:
            return data.BMIRange
        case .fattyLiver:
            return (50 , 80)
        default:
            return (0,0)
        }
    }
}

struct EvaluationDetailExtendViewModel {
    var type: EvaluationDetailExtendType
    var data: ScaleResultProtocol?
    
    init(type: EvaluationDetailExtendType) {
        self.type = type
    }
    
    var range: (Float, Float) {
        if data != nil {
            return type.range(data!)
        }
        return (0,0)
    }
    
    var value: String {
        if data != nil {
            return type.value(data!)
        }
        return "0"
    }
    
    var unit: String {
        if data != nil {
            return type.unit(data!)
        }
        return ""
    }
    
    var levelDescription: (String, String, String) {
        if data != nil {
            return type.levelDescription(data!)
        }
        return ("","","")
    }
    
    var valueIsNumber: Bool {
        var isNumber = true
        for c in value.characters {
            if c == "0" || c == "1" || c == "2" || c == "3" || c == "4" || c == "5" || c == "6" || c == "7" || c == "8" || c == "9" {
                break
            }
            else {
                isNumber = false
                break
            }
        }
        return isNumber
    }
    var status: ValueStatus {
        if data != nil {
            return type.status(data!)
        }
        return ValueStatus.High
    }
}
