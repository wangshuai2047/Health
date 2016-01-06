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
        let params = ["userId": "\(userId)"]
        
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
    static func completeUserInfo(userId: Int, gender: Bool, height: UInt8, age: UInt8, name: String, phone: String?, organizationCode: String?, imageURL: String?, complete: ((imageURL: String?, error: NSError?) -> Void)) {
        
//        complete(error: nil)
//        return
        
        var params = ["userId": NSNumber(integer: userId), "gender": NSNumber(integer: gender ? 1 : 2), "height": NSNumber(unsignedChar: height), "age": NSNumber(unsignedChar: age), "name": name]
        
        if phone != nil {
            params["phone"] = phone!
        }
        else {
            params["phone"] = ""
        }
        
        if organizationCode != nil {
            params["organizationCode"] = organizationCode!
        }
        else {
            params["organizationCode"] = ""
        }
        
        if imageURL != nil {
            
            if let image = UIImage(contentsOfFile: imageURL!) {
                let data = UIImageJPEGRepresentation(image, 1)
                
                let options: NSDataBase64EncodingOptions = [
                    .Encoding76CharacterLineLength,
                    .EncodingEndLineWithLineFeed
                ]
                if let base64String = data?.base64EncodedStringWithOptions(options) {
                    params["head"] = base64String
                }
            }
            
        }
        
        RequestType.CompleteUserInfo.startRequest(params, completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(imageURL: nil, error: err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(imageURL: jsonObj?["headURL"] as? String, error: nil)
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
    
    static func createUser(pid: Int, name: String, height: Int, age: Int, gender: Bool,imageURL: String?, complete: ((userId: Int?, headURL: String?, NSError?) -> Void)) {
        
        var params = ["pid" : pid, "name" : name, "height" : height, "age" : age, "gender" : NSNumber(integer: gender ? 1 : 2)]
        
        if imageURL != nil {
            if let image = UIImage(contentsOfFile: imageURL!) {
                let data = UIImageJPEGRepresentation(image, 1)
                
                let options: NSDataBase64EncodingOptions = [
                    .Encoding76CharacterLineLength,
                    .EncodingEndLineWithLineFeed
                ]
                if let base64String = data?.base64EncodedStringWithOptions(options) {
                    params["head"] = base64String
                }
            }
        }
        
        RequestType.CreateUser.startRequest(params, completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userId: nil, headURL: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(userId: jsonObj?.valueForKey("userId") as? Int, headURL: jsonObj?.valueForKey("headURL") as? String, nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func deleteUser(pid: Int, userId: Int, complete: ((NSError?) -> Void)) {
        RequestType.DeleteUser.startRequest(["userId" : userId, "pid": pid], completionHandler: { (data, response, error) -> Void in
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