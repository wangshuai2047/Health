//
//  AdsRequest.swift
//  Health
//
//  Created by Yalin on 15/8/18.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct RequestLoginAdModel {
    let imageURL: String
    let linkURL: String
    
    var serverImageURL: String {
        return Request.requestPHPPathURL() + imageURL
    }
}

struct AdsRequest {
    
    
    static func queryLaunchAds(_ complete: @escaping ((_ ad: RequestLoginAdModel?, _ error: NSError?) -> Void)) {
        
        RequestType.QueryLaunchAds.startRequest([:], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(RequestLoginAdModel(imageURL: jsonObj!.value(forKey: "imageURL") as! String, linkURL: jsonObj!.value(forKey: "targetURL") as! String), nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func queryActivityAds(_ userId: Int, complete: @escaping ((_ ads: [RequestLoginAdModel]?, _ error: NSError?) -> Void)) {
        RequestType.QueryActivityAds.startRequest(["userId" : userId as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                let ads = jsonObj?.value(forKey: "ads") as? [[String : String]]
                
                var adModels: [RequestLoginAdModel] = []
                for adInfo: [String : String] in ads! {
                    adModels += [RequestLoginAdModel(imageURL: adInfo["imageURL"]!, linkURL: adInfo["targetURL"]!)]
                }
                complete(adModels, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}
