//
//  YYRequest.swift
//  YYLoginViewController
//
//  Created by Yalin on 15/6/4.
//  Copyright (c) 2015年 yalin. All rights reserved.
//

import Foundation

struct Request {
    
    static func requestURL(_ type : String) -> String {
        let urlString = "http://s.bodivis.com.cn/easygtd/v1/user/\(type)"
        return urlString
    }
    
    
    
    static func startWithRequest(_ url : String, method : String?, params : [String : String]?, completionHandler:  @escaping (_ data: Data? , _ response: URLResponse?, _ error: NSError?) -> Void) {
        
        // create request
        var request : URLRequest = URLRequest(url: URL(string: url)!)
        
        if let m = method {
            request.httpMethod = m
        }
        
        // set body data
        if let bodyStrAndBoundary = generateFormDataBodyStr(params) {
            request.httpBody = bodyStrAndBoundary.bodyStr.data(using: String.Encoding.utf8, allowLossyConversion: true)
            request.setValue("\(bodyStrAndBoundary.bodyStr.lengthOfBytes(using: String.Encoding.utf8))", forHTTPHeaderField: "Content-Length")
            request.setValue("multipart/form-data; boundary=Boundary+\(bodyStrAndBoundary.boundary)", forHTTPHeaderField: "Content-Type")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response:URLResponse?, error: NSError?) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(data, response, self.errorFilter(error))
            })
        } as! (Data?, URLResponse?, Error?) -> Void)
        
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
    
    static func startWithRequest(_ requestType: RequestType, params: [String : AnyObject], completionHandler: @escaping (_ data: Data? , _ response: URLResponse?, _ error: NSError?) -> Void) {
        // create request
        var request : URLRequest = URLRequest(url: URL(string: requestPHPURL())!)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.httpBody = generatePHPStyleBodyStr(requestType.rawValue, params: params).data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response:URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(data, response, self.errorFilter(error as NSError?))
            })
        })
        
        task.resume()
    }
    
    static func generatePHPStyleBodyStr(_ partnerCode: String, params: [String : AnyObject]) -> String {
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
        let timeInterval = Date().timeIntervalSince1970
        let md5Key = String(format: "%i%@", arguments: [Int(timeInterval), key]).md5Value
        
        let httpBodyInfo = [
            "header" : [
                "timestamp" : Int(timeInterval),
                "key" : md5Key,
                "partnerCode" : partnerCode,
                "encryption" : "md5"
            ],
            "body" : params
        ] as [String : Any]
        
        print("request HTTPBody \(httpBodyInfo)")
        
        
        var httpBodyData: Data?
        do {
            httpBodyData = try JSONSerialization.data(withJSONObject: httpBodyInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let error1 as NSError {
            error = error1
            httpBodyData = nil
        }
        if error != nil {
            assert(true, error!.description)
        }
        
        return String(NSString(data: httpBodyData!, encoding: String.Encoding.utf8.rawValue)!)
    }
}

// data wrapper
extension Request {
    
    static func generateFormDataBodyStr(_ params : [String : String]?) -> (bodyStr : String, boundary : String)? {
        
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
    
    fileprivate static func errorFilter(_ error : NSError?) -> NSError? {
        return error
    }
}
