//
//  QQHealthManager.swift
//  Health
//
//  Created by Yalin on 15/10/16.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class QQHealthManager: NSObject {

    static let sharedInstance = QQHealthManager()
    
    // 步行数据
    func saveWalkData(_ startDate: Date, endDate: Date, steps: Double, completion: @escaping ((NSError?) -> Void)) {
        ShareSDKHelper.syncStepsDatas(startDate, distance: Int(steps * 0.75), steps: Int(steps), duration: Int(endDate.timeIntervalSince(startDate)), calories: Int(steps * 500), complete: completion)
    }
    
    // 睡眠数据
    func saveSleepData(_ startDate: Date, endDate: Date, sleepTime: Int, deepSleepTime: Int, completion: @escaping ((NSError?) -> Void)) {
        
//        睡眠阶段详情数据,格式[起始时间点,睡眠状态] (1-睡醒,2-浅睡眠,3-深睡眠), 当深睡, 浅睡,清醒,有状态改变时记录,例如 [1405585306,2],[1405591306,3],[1405631306,2]
        
        let detailString = "[\(Int(startDate.timeIntervalSince1970)),2],[\(Int(endDate.addingTimeInterval(Double(-1 * deepSleepTime)).timeIntervalSince1970)),3],[\(endDate.timeIntervalSince1970),1]"
        
        ShareSDKHelper.syncSleepDatas(startDate, end_time: endDate, total_time: sleepTime + deepSleepTime, light_sleep: sleepTime - deepSleepTime, deep_sleep: deepSleepTime, awake_time: Int(endDate.timeIntervalSince(startDate)) - sleepTime, detail: detailString, complete: completion)
    }
    
    // 体重
    func saveWeightData(_ weight: Float, fatPercentage: Float, bmi: Float, date: Date, completion: @escaping ((NSError?) -> Void)) {
        ShareSDKHelper.syncBodyDatas(date, weight: weight, fat_per: fatPercentage, bmi: bmi, complete: completion)
    }
}
