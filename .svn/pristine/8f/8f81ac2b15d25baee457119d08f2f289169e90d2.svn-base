//
//  WeightStatus.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

enum WeightStatus {
    case thin   // 瘦
    case normal // 正常
    case littleFat  // 轻度肥胖
    case middleFat  // 中度肥胖
    case highFat   // 重度肥胖
    case veryFat    // 极度肥胖
    
    init(fatPercentage: Float, gender: Bool) {
        if gender {
            if fatPercentage < 16 {
                self = .thin
            }
            else if fatPercentage < 20 {
                self = .normal
            }
            else if fatPercentage < 24 {
                self = .littleFat
            }
            else if fatPercentage < 28 {
                self = .middleFat
            }
            else if fatPercentage < 30 {
                self = .highFat
            }
            else {
                self = .veryFat
            }
        }
        else {
            if fatPercentage < 18 {
                self = .thin
            }
            else if fatPercentage < 22 {
                self = .normal
            }
            else if fatPercentage < 26 {
                self = .littleFat
            }
            else if fatPercentage < 29 {
                self = .middleFat
            }
            else if fatPercentage < 35 {
                self = .highFat
            }
            else {
                self = .veryFat
            }
        }
    }
    
    var description: String {
        switch self {
        case .thin:
            return "过瘦"
        case .normal:
            return "正常"
        case .littleFat:
            return "轻度肥胖"
        case .middleFat:
            return "中度肥胖"
        case .highFat:
            return "重度肥胖"
        case .veryFat:
            return "极度肥胖"
        }
    }
}
