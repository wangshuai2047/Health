//
//  ResponseDataFilter.swift
//  YYLoginViewController
//
//  Created by Yalin on 15/6/15.
//  Copyright (c) 2015年 yalin. All rights reserved.
//

import Foundation

extension Request {
    
    static func dataFilter(data: NSData!) -> (jsonObj : AnyObject? , error : NSError?) {
        
        var err : NSError?
        
        do {
            let result : NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data,  options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            let message: AnyObject? = result?.valueForKey("errormsg")
            print("responseJson", jsonStr)
            print("responseStr: \(result) \(message)")
            
            if let jsonObj = result {
                
                if let code = jsonObj.valueForKey("code") as? Int {
                    if code == 10000 {
                        // 请求成功
                        return (result, nil)
                    }
                    else {
                        // 请求失败
                        if let msg = jsonObj.valueForKey("errormsg") as? String {
                            err = NSError(domain: "Server logic error", code: code, userInfo: [NSLocalizedDescriptionKey : msg])
                        }
                        else
                        {
                            err = NSError(domain: "Server logic error", code: code, userInfo: [NSLocalizedDescriptionKey : "Server not return the detail error message"])
                        }
                    }
                }
            }
            return (nil, err)
        } catch let error1 as NSError {
            return (nil, error1)
        }
        
        
        
        
    }
    
    // 处理返回数据
    static func dealResponseData(data: NSData!, response: NSURLResponse!, error: NSError!) -> (jsonObj : AnyObject? , error : NSError?) {
        if let err = error {
            return (nil, err)
        }
        else {
            let result = Request.dataFilter(data)
            return result
        }
    }
}