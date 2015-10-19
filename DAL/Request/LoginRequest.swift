//
//  YYLoginRequest.swift
//  YYLoginViewController
//
//  Created by Yalin on 15/6/3.
//  Copyright (c) 2015年 yalin. All rights reserved.
//

import UIKit

struct  LoginRequest {
    
    // 通过用户名密码登录
    static func login(username: String, password: String, complete : (([String: AnyObject]? , NSError?) -> Void)) {
        
        // 假数据
//        complete(["userId" : NSNumber(integer: 123)], nil)
//        return;
        
        let pushToken = "fefjewioafjaeofja"
        
        let loginUrlStr = Request.requestURL("login.ac")
        Request.startWithRequest(loginUrlStr, method: "POST", params: ["phone" : username, "password" : password, "pushToken" : pushToken]) { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil, nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        }
    }
    
    static func login(phone: String, captchas: String, complete : ((userInfo: [String: AnyObject]? , NSError?) -> Void)) {
        RequestType.Login.startRequest(["phone" : phone, "captchas" : captchas], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userInfo: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(userInfo: jsonObj?.valueForKey("info") as? [String: AnyObject], nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 获取验证码
    static func queryCaptchas(phone: String, complete: ((String?, NSError?) -> Void)) {
        
        RequestType.QueryCaptchas.startRequest(["phone" : phone], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete("", err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?["authCode"] as? String, nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方登录
    static func loginThirdPlatform(name: String, headURLStr: String, openId: String, type: ThirdPlatformType, complete: ((userInfo: [String: AnyObject]?, NSError?) -> Void)) {
        
        RequestType.LoginThirdPlatform.startRequest(["name": name, "headurl": headURLStr, "openid": openId, "type": type.rawValue], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userInfo: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: [String: AnyObject]? = result.jsonObj as? [String: AnyObject]
                complete(userInfo: jsonObj?["info"] as? [String: AnyObject], nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方绑定 字段：userId 用户id  绑定类型 type:1 微信  2：微博  3：qq登录  openid：第三方的id
    static func bindThirdPlatform(name: String, openId: String, type: ThirdPlatformType, complete: ((userInfo: [String: AnyObject]?, NSError?) -> Void)) {
        
        RequestType.LoginThirdPlatform.startRequest(["name": name, "openid": openId, "type": type.rawValue], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userInfo: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: [String: AnyObject]? = result.jsonObj as? [String: AnyObject]
                complete(userInfo: jsonObj?["info"] as? [String: AnyObject], nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}


