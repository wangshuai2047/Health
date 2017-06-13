//
//  Physique.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

// 体型
public enum Physique: Int {
    case hiddenFat = 1      // 隐性肥胖  hiddenFat
    case lotOfFat       // 脂肪过多 lotOfFat
    case fat            // 肥胖   fat
    case littleMuscle   // 肌肉不足 littleMuscle
    case health          // 健康  health
    case lotOfMuscle    // 超重肌肉 lotOfMuscle
    case spare          // 消瘦   spareFemale
    case littleFat      // 低脂肪  littleFat
    case athlete        // 运动员  athlete
    
    // gender true为男  false为女
    func imageName(_ gender: Bool) -> String {
        if gender {
            return self.imageName
        }
        else {
            return self.imageName + "Female"
        }
    }
    
    func selectedImageName(_ gender: Bool) -> String {
        return imageName(gender) + "Selected"
    }
    
    fileprivate var imageName: String {
        switch self {
        case .hiddenFat:
            return "hiddenFat"
        case .lotOfFat:
            return "lotOfFat"
        case .fat:
            return "fat"
        case .littleMuscle:
            return "littleMuscle"
        case .health:
            return "health"
        case .lotOfMuscle:
            return "lotOfMuscle"
        case .spare:
            return "spare"
        case .littleFat:
            return "littleFat"
        case .athlete:
            return "athlete"
        }
    }
    
    var description: String {
        switch self {
        case .hiddenFat:
            return "隐形肥胖型"
        case .lotOfFat:
            return "脂肪过多型"
        case .fat:
            return "肥胖型"
        case .littleMuscle:
            return "肌肉不足型"
        case .health:
            return "健康匀称型"
        case .lotOfMuscle:
            return "超重肌肉型"
        case .spare:
            return "消瘦型"
        case .littleFat:
            return "低脂肪型"
        case .athlete:
            return "运动员型"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .hiddenFat:
            return "体重较轻，而体内脂肪含量相对较高，有心脑血管疾病风险，需要注意减脂。"
        case .lotOfFat:
            return "虽然体重不高，但脂肪含量较高，对健康不利，应适当减脂。"
        case .fat:
            return "体型偏胖，体内脂肪含量高，存在健康风险，需注意改善。"
        case .littleMuscle:
            return "体重适中，但肌肉比例较低，应注意锻炼。"
        case .health:
            return "您的体型适中，不胖不瘦，成分合理，请保持。"
        case .lotOfMuscle:
            return "体重高于正常范围，但体脂肪不高，属于肌肉发达，可以保持。"
        case .spare:
            return "体重和体脂肪都偏低，应增加营养和热量摄入。"
        case .littleFat:
            return "体重适中，但脂肪含量较低，可适当补充脂肪摄入。"
        case .athlete:
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
                self = .spare
            }
            else if BMI > highBMI {
                self = .athlete
            }
            else {
                self = .littleFat
            }
        }
        else if fatPercentage > highFatPercentage {
            if BMI < lowBMI {
                self = .hiddenFat
            }
            else if BMI > highBMI {
                self = .fat
            }
            else {
                self = .lotOfFat
            }
        }
        else {
            if BMI < lowBMI {
                self = .littleMuscle
            }
            else if BMI > highBMI {
                self = .lotOfMuscle
            }
            else {
                self = .health
            }
        }
    }
}
