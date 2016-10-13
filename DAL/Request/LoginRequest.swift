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
    static func login(_ username: String, password: String, complete : @escaping (([String: AnyObject]? , NSError?) -> Void)) {
        
        // 假数据
//        complete(["userId" : NSNumber(integer: 123)], nil)
//        return;
        
        let pushToken = "fefjewioafjaeofja"
        
        let loginUrlStr = Request.requestURL("login.ac")
        Request.startWithRequest(loginUrlStr, method: "POST", params: ["phone" : username, "password" : password, "pushToken" : pushToken]) { (data : Data?, response : URLResponse?, error : Error?) in
            
            let result = Request.dealResponseData(data, response: response, error: error as? NSError)
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
    
    static func login(_ phone: String, captchas: String, complete : @escaping ((_ userInfo: [String: AnyObject]? , NSError?) -> Void)) {
        RequestType.Login.startRequest(["phone" : phone as AnyObject, "captchas" : captchas as AnyObject], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                var info = jsonObj?.value(forKey: "info") as? [String: AnyObject]
                info?["child"] = jsonObj?.value(forKey: "child") as AnyObject?
                info?["app"] = jsonObj?.value(forKey: "app") as AnyObject?
                info?["usertype"] = jsonObj?.value(forKey: "usertype") as AnyObject?
                complete(info, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 获取验证码
    static func queryCaptchas(_ phone: String, complete: @escaping ((String?, NSError?) -> Void)) {
        
        RequestType.QueryCaptchas.startRequest(["phone" : phone as AnyObject], completionHandler: { (data, response, error) -> Void in
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
    static func loginThirdPlatform(_ name: String, headURLStr: String, openId: String, type: ThirdPlatformType, unionid: String?, complete: @escaping ((_ userInfo: [String: AnyObject]?, NSError?) -> Void)) {
        
        var info = ["name": name, "headURL": headURLStr, "openId": openId, "type": type.rawValue]
        
        if unionid != nil {
            info["unionid"] = unionid
        }
        // , token: String?
//        if token != nil {
//            info["token"] = token
//        }
        
        RequestType.LoginThirdPlatform.startRequest(info as [String : AnyObject], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                
                var info = jsonObj?.value(forKey: "info") as? [String: AnyObject]
                info?["child"] = jsonObj?.value(forKey: "child") as AnyObject?
                info?["app"] = jsonObj?.value(forKey: "app") as AnyObject?
                info?["usertype"] = jsonObj?.value(forKey: "usertype") as AnyObject?
                complete(info, nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 第三方绑定 字段：userId 用户id  绑定类型 type:1 微信  2：微博  3：qq登录  openid：第三方的id
    static func bindThirdPlatform(_ userId: Int, openId: String, type: ThirdPlatformType, complete: @escaping ((NSError?) -> Void)) {
        
        RequestType.BindThirdPlatform.startRequest(["userId": userId as AnyObject, "openId": openId as AnyObject, "type": type.rawValue as AnyObject], completionHandler: { (data, response, error) -> Void in
            
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
    static func cancelBindThirdPlatform(_ userId: Int, openId: String, type: ThirdPlatformType, complete: @escaping ((NSError?) -> Void)) {
        
        RequestType.CancelBindThirdPlatform.startRequest(["userId": userId as AnyObject, "openId": openId as AnyObject, "type": type.rawValue as AnyObject], completionHandler: { (data, response, error) -> Void in
            
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


