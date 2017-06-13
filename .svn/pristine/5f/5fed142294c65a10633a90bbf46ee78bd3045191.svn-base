//
//  ActivityManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct ActivityManager {
    static func queryActiveAds(_ complete: @escaping ((_ ads: [RequestLoginAdModel]?, _ error: NSError?) -> Void)) {
        AdsRequest.queryActivityAds(UserData.sharedInstance.userId!, complete: complete)
    }
    
    // 获取积分
    static func queryScoreAds(_ complete: @escaping (_ score: Int?, _ rank: Int?, _ error: NSError?) -> Void) {
        ScoreRequest.queryScore(UserManager.mainUser.userId) { (allscore, monthscore, rank, monthrank, error: NSError?) -> Void in
            if error == nil { // extra argument in call
                complete(allscore!, rank, nil)
            }
            else {
                complete(nil, nil, error)
            }
        }
    }
    
    
    static func queryActivityDatas() -> (walker: Bool, sleeper: Bool, evaluationer: Bool, sharer: Bool) {
        
        var result = (true, true, true, true)
        
        //[(walkStep,runStep,sleepTime,deepSleepTime)]
        let datas = GoalManager.querySevenDaysData()
        
        var endDate = Date(timeIntervalSinceNow: 24 * 60 * 60).zeroTime()
        for index in 1...7 {
            let beginDate = endDate.addingTimeInterval(-24 * 60 * 60)
            
            let (walkStep,_,sleepTime,deepSleepTime) = datas[index]
            
            // 是否是不倦行者
            if result.0 {
                
                if walkStep < 10000 {
                    result.0 = false
                }
            }
            
            // 是否是安睡达人
            if result.1 {
                if sleepTime + deepSleepTime < 8 * 60 {
                    result.1 = false
                }
            }
            
            // 评测专家
            if result.2 {
                let list = DBManager.sharedInstance.queryEvaluationDatas(beginDate, endTimescamp: endDate, userId: UserData.sharedInstance.userId!)
                if list.count == 0 {
                    result.2 = false
                }
            }
            
            // 分享狂人
            if result.3 {
                let list = DBManager.sharedInstance.queryShareDatas(beginDate, endDate: endDate)
                if list.count == 0 {
                    result.3 = false
                }
            }
            
            endDate = beginDate
        }
        return result
    }
}
