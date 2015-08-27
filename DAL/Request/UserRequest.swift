//
//  UserRequest.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct UserRequest {
    
    // 上传头像
    static func uploadHeadIcon(userId: UInt8, imageURL: NSURL, complete: ((error: NSError?) -> Void)) {
        let urlStr = Request.requestURL("")
        var params = ["userId": "\(userId)"]
        
        Request.startWithRequest(urlStr, method: "POST", params: params) { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(error: err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                // warning
                
                complete(error: nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        }
    }
    
    // 完善个人资料
    static func completeUserInfo(userId: UInt8, gender: UInt8, height: UInt8, age: UInt8, name: String, phone: String?, organizationCode: String?, complete: ((error: NSError?) -> Void)) {
        
        complete(error: nil)
        return
        
        let urlStr = Request.requestURL("")
        var params = ["userId": "\(userId)", "gender": "\(gender)", "height": "\(height)", "age": "\(age)", "name": "\(name)"]
        
        if phone != nil {
            params["phone"] = phone!
        }
        
        if organizationCode != nil {
            params["organizationCode"] = organizationCode!
        }
        
        Request.startWithRequest(urlStr, method: "POST", params: params) { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(error: err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                // warning
                
                complete(error: nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        }
    }
}