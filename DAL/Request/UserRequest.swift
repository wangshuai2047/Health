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
    static func completeUserInfo(userId: Int, gender: Bool, height: UInt8, age: UInt8, name: String, phone: String?, organizationCode: String?, imageURL: NSURL?, complete: ((error: NSError?) -> Void)) {
        
        complete(error: nil)
        return
        
        var params = ["userId": "\(userId)", "gender": "\(gender)", "height": "\(height)", "age": "\(age)", "name": "\(name)"]
        
        if phone != nil {
            params["phone"] = phone!
        }
        
        if organizationCode != nil {
            params["organizationCode"] = organizationCode!
        }
        
        if imageURL != nil {
            if let base64String = NSData(contentsOfURL: imageURL!)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0)) {
                params["head"] = base64String
            }
        }
        
        RequestType.CompleteUserInfo.startRequest(params, completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(error: err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete(error: nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func feedBack(userId: Int, feedback: String, complete: ((NSError?) -> Void)) {
        RequestType.FeedBack.startRequest(["userId" : userId, "feedback" : feedback], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete( nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func createUser(name: String, height: Int, age: Int, gender: Int, complete: ((userId: Int?, NSError?) -> Void)) {
        RequestType.CreateUser.startRequest(["name" : name, "height" : height, "age" : age, "gender" : gender], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userId: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(userId: jsonObj?.valueForKey("userId") as? Int, nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func deleteUser(userId: Int, complete: ((NSError?) -> Void)) {
        RequestType.DeleteUser.startRequest(["userId" : userId], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete( nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}