//
//  GoalShowInfo.swift
//  Health
//
//  Created by Yalin on 15/9/17.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

// MARK: - 初始化定义
struct GoalShowInfo {
    var addFatPercentage: Float  // 需改变的体脂率 负数为需降低
    var dayCalorieGoal: Float // 每天需摄入的卡路里
    var dayWalkGoal: Int = 10000        // 每日走多少路
    
    var sevenDaysWalkAverageValue: Int  // 过去七天平均步行多少
    var sevenDaysSleepAverageValue: Int // 过去七天平均睡眠多少
    
    var sevenDaysDatas: [(Int, Int, Int, Int)]
    
    // 脂肪=体重*体脂率，减重我们默认其实就是减脂肪，一周减0.3公斤重量（脂肪），每天要减的热量为0.3*7700/7=330千卡
    init(scaleResult: ScaleResultProtocol, sevenDaysDatas: [(Int, Int, Int, Int)]) {
        // 需改变的体脂率
        addFatPercentage = scaleResult.standardFatPercentage - scaleResult.fatPercentage
        
        let dayCalorie = scaleResult.weight * addFatPercentage * 15
        dayCalorieGoal = dayCalorie + scaleResult.dayNeedCalorie
        
        dayWalkGoal = Int(dayCalorie / 500) == 0 ? 10000 : Int(dayCalorie / 500)
        
        if dayWalkGoal < 0 {
            dayWalkGoal = 10000
        }
        
        var walkSteps: Int = 0
        var walkSleeps: Int = 0
        for (walkStep,_,sleepTime,deepSleepTime) in sevenDaysDatas {
            walkSteps += Int(walkStep)
            walkSleeps += Int(sleepTime)
            walkSleeps += Int(deepSleepTime)
        }
        
        sevenDaysWalkAverageValue = walkSteps / 7
        sevenDaysSleepAverageValue = walkSleeps / 7 / 60
        
        self.sevenDaysDatas = sevenDaysDatas
    }
}

// MARK: - 计算随眠数据
extension GoalShowInfo {
    
    func praseSleepData(data: BraceletResult) {
        
    }
}
