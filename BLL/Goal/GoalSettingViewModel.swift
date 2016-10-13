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
    
    mutating func calculeSuggestDays(_ type: UserGoalData.GoalType, range: Int) -> Int {
        if type == .weight {
            return Int(Float(range) / (0.3 / 7))
        }
        else if type == .fat {
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
    
    mutating func rangeOfGoalType(_ type: UserGoalData.GoalType) -> ([Int], [Int]) {
        
        var dayRange: [Int] = []
        
        for i in 7...60 {
            dayRange.append(i)
        }
        
        var numberRange: [Int] = [0]
        if lastEvaluationData != nil {
            if type == UserGoalData.GoalType.weight {
                // 标准体重
                let sw = lastEvaluationData!.SWRange.0
                let weight = lastEvaluationData!.weight
                
                let weightRange = weight - sw
                
                if weightRange > 0 {
                    for i in 1...Int(weightRange)-1 {
                        numberRange.append(i)
                    }
                }
            }
            else if type == UserGoalData.GoalType.fat {
                // 标准体脂率
                let sfp = lastEvaluationData!.fatPercentageRange.0 * 100
                let fatPercentage = lastEvaluationData!.fatPercentage
                
                let fatPercentageRange = fatPercentage - sfp
                
                if fatPercentageRange > 0 {
                    for i in 1...Int(fatPercentageRange * lastEvaluationData!.weight / 100)-1 {
                        numberRange.append(i)
                    }
                }
            }
        }
        
        return (numberRange,dayRange)
    }
}
