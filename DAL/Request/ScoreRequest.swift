//
//  ScoreRequest.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct ScoreRequest {
    // 'allscore'总积分,'monthscore',当月积分'rank',会员等级 'monthrank' 当月等级
    static func queryScore(userId: Int, complete: ((allscore: Int?, monthscore: Int?, rank: Int?, monthrank: Int?, NSError?) -> Void)) {
        
        RequestType.QueryScore.startRequest(["userId": userId], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(allscore: nil,monthscore: nil,rank: nil,monthrank: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                let scoreInfo = jsonObj?.valueForKey("score") as? NSDictionary
                let allscore = scoreInfo?.valueForKey("allscore") as? Int
                let monthscore = scoreInfo?.valueForKey("monthscore") as? Int
                let rank = scoreInfo?.valueForKey("rank") as? Int
                let monthrank = scoreInfo?.valueForKey("monthrank") as? Int
                complete(allscore: allscore,monthscore: monthscore,rank: rank,monthrank: monthrank,nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func share(userId: Int, type: Int, platform: ThirdPlatformType, complete: ((NSError?) -> Void)) {
        RequestType.Share.startRequest(["userId" : userId, "type": type, "platform": platform.rawValue], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}