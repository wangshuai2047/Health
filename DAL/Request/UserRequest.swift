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
    static func uploadHeadIcon(_ userId: UInt8, imageURL: URL, complete: @escaping ((_ error: NSError?) -> Void)) {
        let urlStr = Request.requestURL("")
        let params = ["userId": "\(userId)"]
        
        Request.startWithRequest(urlStr, method: "POST", params: params) { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                // warning
                
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        }
    }
    
    // 完善个人资料
    static func completeUserInfo(_ userId: Int, gender: Bool, height: UInt8, age: UInt8, name: String, phone: String?, organizationCode: String?, imageURL: String?, complete: @escaping ((_ imageURL: String?, _ error: NSError?) -> Void)) {
        
//        complete(error: nil)
//        return
        
        var params = ["userId": NSNumber(value: userId as Int), "gender": NSNumber(value: gender ? 1 : 2 as Int), "height": NSNumber(value: height as UInt8), "age": NSNumber(value: age as UInt8), "name": name] as [String : Any]
        
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
                
                let options: NSData.Base64EncodingOptions = [
                    .lineLength76Characters,
                    .endLineWithLineFeed
                ]
                if let base64String = data?.base64EncodedString(options: options) {
                    params["head"] = base64String
                }
            }
            
        }
        
        RequestType.CompleteUserInfo.startRequest(params as [String : AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?["headURL"] as? String, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func feedBack(_ userId: Int, feedback: String, complete: @escaping ((NSError?) -> Void)) {
        RequestType.FeedBack.startRequest(["userId" : userId as AnyObject, "feedback" : feedback as AnyObject], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete( nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func createUser(_ pid: Int, name: String, height: Int, age: Int, gender: Bool,imageURL: String?, complete: @escaping ((_ userId: Int?, _ headURL: String?, NSError?) -> Void)) {
        
        var params = ["pid" : pid, "name" : name, "height" : height, "age" : age, "gender" : NSNumber(value: gender ? 1 : 2 as Int)] as [String : Any]
        
        if imageURL != nil {
            if let image = UIImage(contentsOfFile: imageURL!) {
                let data = UIImageJPEGRepresentation(image, 1)
                
                let options: NSData.Base64EncodingOptions = [
                    .lineLength76Characters,
                    .endLineWithLineFeed
                ]
                if let base64String = data?.base64EncodedString(options: options) {
                    params["head"] = base64String
                }
            }
        }
        
        RequestType.CreateUser.startRequest(params as [String : AnyObject], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?.value(forKey: "userId") as? Int, jsonObj?.value(forKey: "headURL") as? String, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func deleteUser(_ pid: Int, userId: Int, complete: @escaping ((NSError?) -> Void)) {
        RequestType.DeleteUser.startRequest(["userId" : userId as AnyObject, "pid": pid as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete( nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}
