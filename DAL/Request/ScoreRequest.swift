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
    static func queryScore(_ userId: Int, complete: @escaping ((_ allscore: Int?, _ monthscore: Int?, _ rank: Int?, _ monthrank: Int?, NSError?) -> Void)) {
        
        RequestType.QueryScore.startRequest(["userId": userId as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil,nil,nil,nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                let scoreInfo = jsonObj?.value(forKey: "score") as? NSDictionary
                let allscore = scoreInfo?.value(forKey: "allscore") as? Int
                let monthscore = scoreInfo?.value(forKey: "monthscore") as? Int
                let rank = scoreInfo?.value(forKey: "rank") as? Int
                let monthrank = scoreInfo?.value(forKey: "monthrank") as? Int
                complete(allscore,monthscore,rank,monthrank,nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func share(_ userId: Int, type: Int, platform: ThirdPlatformType, complete: @escaping ((NSError?) -> Void)) {
        RequestType.Share.startRequest(["userId" : userId as AnyObject, "type": type as AnyObject, "platform": platform.rawValue as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}
