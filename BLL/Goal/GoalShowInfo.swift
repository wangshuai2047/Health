//
//  GoalShowInfo.swift
//  Health
//
//  Created by Yalin on 15/9/17.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

struct GoalShowInfo {
    var addFatPercentage: Float  // 需改变的体脂率 负数为需降低
    var dayCalorieGoal: Float // 每天需摄入的卡路里
    var dayWalkGoal: Int        // 每日走多少路
    
    init(scaleResult: ScaleResult) {
        // 需改变的体脂率
        addFatPercentage = scaleResult.standardFatPercentage - scaleResult.fatPercentage
        
        let dayCalorie = scaleResult.weight * addFatPercentage * 1000 * 15
        dayCalorieGoal = dayCalorie + scaleResult.dayNeedCalorie
        
        dayWalkGoal = Int(dayCalorie / 500)
    }
}
