//
//  YYRequest.swift
//  YYLoginViewController
//
//  Created by Yalin on 15/6/4.
//  Copyright (c) 2015年 yalin. All rights reserved.
//

import Foundation

struct Request {
    
    static func requestURL(type : String) -> String {
        let urlString = "http://s.bodivis.com.cn/easygtd/v1/user/\(type)"
        return urlString
    }
    
    
    
    static func startWithRequest(url : String, method : String?, params : [String : String]?, completionHandler: (data: NSData! , response: NSURLResponse!, error: NSError!) -> Void) {
        
        // create request
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        if let m = method {
            request.HTTPMethod = m
        }
        
        // set body data
        if let bodyStrAndBoundary = generateFormDataBodyStr(params) {
            request.HTTPBody = bodyStrAndBoundary.bodyStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            request.setValue("\(bodyStrAndBoundary.bodyStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))", forHTTPHeaderField: "Content-Length")
            request.setValue("multipart/form-data; boundary=Boundary+\(bodyStrAndBoundary.boundary)", forHTTPHeaderField: "Content-Type")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(data: data, response: response, error: self.errorFilter(error))
            })
        })
        
        task.resume()
    }
}

// PHP Style
extension Request {
    
    static func requestPHPPathURL() -> String {
        return "http://s.bodivis.com.cn/"
    }
    
    static func requestPHPURL() -> String {
        return "http://s.bodivis.com.cn/index.php"
    }
    
    static func startWithRequest(requestType: RequestType, params: [String : AnyObject], completionHandler: (data: NSData! , response: NSURLResponse!, error: NSError!) -> Void) {
        // create request
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestPHPURL())!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 15
        request.HTTPBody = generatePHPStyleBodyStr(requestType.rawValue, params: params).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(data: data, response: response, error: self.errorFilter(error))
            })
        })
        
        task.resume()
    }
    
    static func generatePHPStyleBodyStr(partnerCode: String, params: [String : AnyObject]) -> String {
        var error: NSError? = nil
//        var bodyStr: NSData?
//        do {
//            bodyStr = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
//        } catch let error1 as NSError {
//            error = error1
//            bodyStr = nil
//        }
//        if error != nil {
//            assert(true, error!.description)
//        }
        
        let key = "04c67a23b87bc349cfdf8fa59e980723"
        let timeInterval = NSDate().timeIntervalSince1970
        let md5Key = String(format: "%i%@", arguments: [Int(timeInterval), key]).md5Value
        
        let httpBodyInfo = [
            "header" : [
                "timestamp" : Int(timeInterval),
                "key" : md5Key,
                "partnerCode" : partnerCode,
                "encryption" : "md5"
            ],
            "body" : params
        ]
        
        print("request HTTPBody \(httpBodyInfo)")
        
        
        var httpBodyData: NSData?
        do {
            httpBodyData = try NSJSONSerialization.dataWithJSONObject(httpBodyInfo, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error1 as NSError {
            error = error1
            httpBodyData = nil
        }
        if error != nil {
            assert(true, error!.description)
        }
        
        return String(NSString(data: httpBodyData!, encoding: NSUTF8StringEncoding)!)
    }
}

// data wrapper
extension Request {
    
    static func generateFormDataBodyStr(params : [String : String]?) -> (bodyStr : String, boundary : String)? {
        
        let boundary = String(format: "%08X%08X", arc4random(),arc4random())
        // add form data
        var bodyStr = "--Boundary+\(boundary)--\r\n"
        if let p = params {
            for (key , value) in p {
                bodyStr += "--Boundary+\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n"
            }
        }
        else {
            return nil
        }
        bodyStr += "\r\n--Boundary+\(boundary)--\r\n"
        
        return (bodyStr, boundary)
    }
    
    
}

// error filter
extension Request {
    
    private static func errorFilter(error : NSError?) -> NSError? {
        return error
    }
}