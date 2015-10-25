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
    
    mutating func rangeOfGoalType(type: UserGoalData.GoalType) -> ([Int], [Int]) {
        var numberRange: [Int] = [0]
        var dayRange: [Int] = [0]
        if lastEvaluationData != nil {
            if type == UserGoalData.GoalType.Weight {
                // 标准体重
                let sw = lastEvaluationData!.SW
                let weight = lastEvaluationData!.weight
                
                let weightRange = weight - sw
                
                if weightRange > 0 {
                    for var i = 1; i < Int(weightRange); i++ {
                        numberRange.append(i)
                    }
                }
                
                let totalDays = Int(weightRange * 7 / 0.3)
                if totalDays > 0 {
                    for var i = 1; i < totalDays; i++ {
                        dayRange.append(i)
                    }
                }
            }
            else if type == UserGoalData.GoalType.Fat {
                // 标准体脂率
                let sfp = lastEvaluationData!.standardFatPercentage
                let fatPercentage = lastEvaluationData!.fatPercentage
                
                let fatPercentageRange = fatPercentage - sfp
                
                if fatPercentageRange > 0 {
                    for var i = 1; i < Int(fatPercentageRange * lastEvaluationData!.weight); i++ {
                        numberRange.append(i)
                    }
                    
                    // 每周减0.06千克脂肪
                    let totalDays = Int(fatPercentageRange * lastEvaluationData!.weight * 7 / 0.06)
                    if totalDays > 0 {
                        for var i = 1; i < totalDays; i++ {
                            dayRange.append(i)
                        }
                    }
                }
            }
        }
        
        return (numberRange,dayRange)
    }
}
