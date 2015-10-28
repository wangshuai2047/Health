//
//  GoalSettingViewModel.swift
//  Health
//
//  Created by Yalin on 15/10/24.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

struct GoalSettingViewModel {
    
    lazy var lastEvaluationData = GoalManager.lastEvaluationData()
    
    mutating func calculeSuggestDays(type: UserGoalData.GoalType, range: Int) -> Int {
        if type == .Weight {
            return Int(Float(range) / (0.3 / 7))
        }
        else if type == .Fat {
            if lastEvaluationData != nil {
                if lastEvaluationData!.gender {
                    return Int(Float(range) / ((0.3 * 0.15) / 7))
                }
                else {
                    return Int(Float(range) / ((0.3 * 0.25) / 7))
                }
            }
        }
        return 0
    }
    
    mutating func rangeOfGoalType(type: UserGoalData.GoalType) -> ([Int], [Int]) {
        
        var dayRange: [Int] = []
        for var i = 7; i <= 60; i++ {
            dayRange.append(i)
        }
        
        var numberRange: [Int] = [0]
        if lastEvaluationData != nil {
            if type == UserGoalData.GoalType.Weight {
                // 标准体重
                let sw = lastEvaluationData!.SWRange.0
                let weight = lastEvaluationData!.weight
                
                let weightRange = weight - sw
                
                if weightRange > 0 {
                    for var i = 1; i < Int(weightRange); i++ {
                        numberRange.append(i)
                    }
                }
            }
            else if type == UserGoalData.GoalType.Fat {
                // 标准体脂率
                let sfp = lastEvaluationData!.fatPercentageRange.0
                let fatPercentage = lastEvaluationData!.fatPercentage
                
                let fatPercentageRange = fatPercentage - sfp
                
                if fatPercentageRange > 0 {
                    for var i = 1; i < Int(fatPercentageRange * lastEvaluationData!.weight / 100); i++ {
                        numberRange.append(i)
                    }
                }
            }
        }
        
        return (numberRange,dayRange)
    }
}
