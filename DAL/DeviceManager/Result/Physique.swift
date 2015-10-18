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
    case HiddenFat = 1      // 隐性肥胖  hiddenFatFemaleSelected
    case LotOfFat       // 脂肪过多 lotOfFatFemaleSelected
    case Fat            // 肥胖   fatFemaleSelected
    case LittleMuscle   // 肌肉不足 littleMuscleFemaleSelected
    case Health          // 健康  healthFemaleSelected
    case LotOfMuscle    // 超重肌肉 lotOfMuscleFemaleSelected
    case Spare          // 消瘦   spareFemaleSelected
    case LittleFat      // 低脂肪  littleFatFemaleSelected
    case Athlete        // 运动员  athleteFemaleSelected
    
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