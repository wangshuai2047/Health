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
    static func login(username: String, password: String, complete : ((NSDictionary? , NSError?) -> Void)?) {
        
        let pushToken = "fefjewioafjaeofja"
        
        let loginUrlStr = Request.requestURL("login.ac")
        Request.startWithRequest(loginUrlStr, method: "POST", params: ["phone" : username, "password" : password, "pushToken" : pushToken]) { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if complete != nil {
                if let err = result.error {
                    complete!(nil, err)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                    #endif
                }
                else {
                    let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                    complete!(jsonObj, nil)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                    #endif
                }
            }
        }
    }
    
    // 获取验证码
    static func queryCaptchas(phone: String, complete: ((String?, NSError?) -> Void)?) {
        let queryCaptchasUrl = Request.requestURL("queryCap");
        Request.startWithRequest(queryCaptchasUrl, method: "POST", params: ["phone": phone]) { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if complete != nil {
                if let err = result.error {
                    complete!(nil, err)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                    #endif
                }
                else {
                    let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                    complete!(jsonObj?["captchas"] as? String, nil)
                    #if DEBUG
                        println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                    #endif
                }
            }
        }
        
    }
}


