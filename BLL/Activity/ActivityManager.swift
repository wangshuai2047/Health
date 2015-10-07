//
//  ActivityManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct ActivityManager {
    static func queryActiveAds(complete: ((ads: [RequestLoginAdModel]?, error: NSError?) -> Void)) {
        AdsRequest.queryActivityAds(UserData.shareInstance().userId!, complete: complete)
    }
    
    // 获取积分
    static func queryScoreAds(complete: ((score: Float?, error: NSError?)) -> Void) {
        ScoreRequest.queryScore(UserData.shareInstance().userId!, complete: complete)
    }
    
    
    static func queryActivityDatas() -> (walker: Bool, sleeper: Bool, evaluationer: Bool, sharer: Bool) {
        
        var result = (true, true, true, true)
        
        var endDate = NSDate(timeIntervalSinceNow: 24 * 60 * 60).zeroTime()
        for _ in 0...6 {
            let beginDate = endDate.dateByAddingTimeInterval(-24 * 60 * 60)
            
            // 是否是不倦行者
            if result.0 {
                let list = DBManager.shareInstance().queryGoalData(beginDate, endDate: endDate)
                if list.count == 0 {
                    result.0 = false
                }
            }
            
            // 是否是安睡达人
            if result.1 {
                let list = DBManager.shareInstance().queryGoalData(beginDate, endDate: endDate)
                if list.count == 0 {
                    result.1 = false
                }
            }
            
            // 评测专家
            if result.2 {
                let list = DBManager.shareInstance().queryEvaluationDatas(beginDate, endTimescamp: endDate, userId: UserData.shareInstance().userId!)
                if list.count == 0 {
                    result.2 = false
                }
            }
            
            // 分享狂人
            if result.3 {
                let list = DBManager.shareInstance().queryShareDatas(beginDate, endDate: endDate)
                if list.count == 0 {
                    result.3 = false
                }
            }
            
            endDate = beginDate
        }
        return result
    }
}