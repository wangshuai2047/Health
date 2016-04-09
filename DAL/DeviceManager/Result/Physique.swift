//
//  Physique.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

// 体型
enum Physique: Int {
    case HiddenFat = 1      // 隐性肥胖  hiddenFat
    case LotOfFat       // 脂肪过多 lotOfFat
    case Fat            // 肥胖   fat
    case LittleMuscle   // 肌肉不足 littleMuscle
    case Health          // 健康  health
    case LotOfMuscle    // 超重肌肉 lotOfMuscle
    case Spare          // 消瘦   spareFemale
    case LittleFat      // 低脂肪  littleFat
    case Athlete        // 运动员  athlete
    
    // gender true为男  false为女
    func imageName(gender: Bool) -> String {
        if gender {
            return self.imageName
        }
        else {
            return self.imageName + "Female"
        }
    }
    
    func selectedImageName(gender: Bool) -> String {
        return imageName(gender) + "Selected"
    }
    
    private var imageName: String {
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
    
    var detailDescription: String {
        switch self {
        case .HiddenFat:
            return "体重较轻，而体内脂肪含量相对较高，有心脑血管疾病风险，需要注意减脂。"
        case .LotOfFat:
            return "虽然体重不高，但脂肪含量较高，对健康不利，应适当减脂。"
        case .Fat:
            return "体型偏胖，体内脂肪含量高，存在健康风险，需注意改善。"
        case .LittleMuscle:
            return "体重适中，但肌肉比例较低，应注意锻炼。"
        case .Health:
            return "您的体型适中，不胖不瘦，成分合理，请保持。"
        case .LotOfMuscle:
            return "体重高于正常范围，但体脂肪不高，属于肌肉发达，可以保持。"
        case .Spare:
            return "体重和体脂肪都偏低，应增加营养和热量摄入。"
        case .LittleFat:
            return "体重适中，但脂肪含量较低，可适当补充脂肪摄入。"
        case .Athlete:
            return "体重高于正常范围，但体脂肪略低，应为长期有氧运动的结果，可以保持。"
        }
    }
    
    init (gender: Bool, fatPercentage: Float, BMI: Float, lowFatPercentage: Float, highFatPercentage: Float) {
//    init (gender: Bool, fatPercentage: Float, BMI: Float) {
//        let lowFatPercentage: Float = gender ? 10 : 20
//        let highFatPercentage: Float = gender ? 20 : 30
    
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