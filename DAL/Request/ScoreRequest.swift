//
//  ScoreRequest.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct ScoreRequest {
    static func queryScore(userId: Int, complete: ((Float?, NSError?) -> Void)) {
        
        RequestType.QueryScore.startRequest(["userId": userId], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete((jsonObj?.valueForKey("score") as? NSString)?.floatValue, nil)
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