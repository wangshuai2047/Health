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
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
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
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                var info = jsonObj?.valueForKey("info") as? [String: AnyObject]
                info?["child"] = jsonObj?.valueForKey("child")
                info?["app"] = jsonObj?.valueForKey("app")
                info?["usertype"] = jsonObj?.valueForKey("usertype")
                complete(userInfo: info, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
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
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?["authCode"] as? String, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方登录
    static func loginThirdPlatform(name: String, headURLStr: String, openId: String, type: ThirdPlatformType, unionid: String?, complete: ((userInfo: [String: AnyObject]?, NSError?) -> Void)) {
        
        var info = ["name": name, "headURL": headURLStr, "openId": openId, "type": type.rawValue]
        
        if unionid != nil {
            info["unionid"] = unionid
        }
        
        RequestType.LoginThirdPlatform.startRequest(info, completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(userInfo: nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                var info = jsonObj?.valueForKey("info") as? [String: AnyObject]
                info?["child"] = jsonObj?.valueForKey("child")
                info?["app"] = jsonObj?.valueForKey("app")
                info?["usertype"] = jsonObj?.valueForKey("usertype")
                complete(userInfo: info, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方绑定 字段：userId 用户id  绑定类型 type:1 微信  2：微博  3：qq登录  openid：第三方的id
    static func bindThirdPlatform(userId: Int, openId: String, type: ThirdPlatformType, complete: ((NSError?) -> Void)) {
        
        RequestType.BindThirdPlatform.startRequest(["userId": userId, "openId": openId, "type": type.rawValue], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方取消绑定 // 解除绑定接口  传 userId 和  openId 的值就行
    static func cancelBindThirdPlatform(userId: Int, openId: String, type: ThirdPlatformType, complete: ((NSError?) -> Void)) {
        
        RequestType.CancelBindThirdPlatform.startRequest(["userId": userId, "openId": openId, "type": type.rawValue], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}


