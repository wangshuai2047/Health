//
//  AdsRequest.swift
//  Health
//
//  Created by Yalin on 15/8/18.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct LoginAdModel {
    let imageURL: String
    let linkURL: String
}

struct AdsRequest {
    static func queryLoginAds(complete: ((ads: [LoginAdModel], error: NSError?) -> Void)?) {
        let urlStr = Request.requestURL("")
        
        Request.startWithRequest(urlStr, method: "POST", params: nil) { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if complete != nil {
                if let err = result.error {
                    complete!(ads: [], error: err)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                    #endif
                }
                else {
                    let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                    
                    // warning
                    
                    complete!(ads: [], error: nil)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                    #endif
                }
            }
        }
    }
}
