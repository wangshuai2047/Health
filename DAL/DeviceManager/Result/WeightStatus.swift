//
//  WeightStatus.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

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