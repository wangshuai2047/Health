//
//  EvaluationRequest.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct EvaluationRequest {
    
    // 获取评测数据
    static func queryEvaluationDatas(userId: Int, startDate: NSDate, endDate: NSDate, complete : ((datas: [[String: AnyObject]]? , NSError?) -> Void)) {
        RequestType.QueryEvaluationDatas.startRequest(["userId": userId, "startTimescamp" : startDate.secondTimeInteval(), "endTimescamp" : endDate.secondTimeInteval()], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(datas: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(datas: jsonObj?.valueForKey("datas") as? [[String: AnyObject]], nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 上传评测数据
    static func uploadEvaluationDatas(datas: [[String: AnyObject]]? , complete: ((info: [[String: AnyObject]]?, NSError?) -> Void)) {
        
        let jsonStr = NSString(data: NSJSONSerialization.dataWithJSONObject(datas!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!, encoding: NSUTF8StringEncoding)
        
        RequestType.UploadEvaluationDatas.startRequest(["datas": jsonStr!], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(info: nil, err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(info: jsonObj?.valueForKey("info") as? [[String: AnyObject]], nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func deleteEvaluationData(dataId: String, userId: Int, complete: ((NSError?) -> Void)) {
        RequestType.DeleteEvaluationData.startRequest(["userId": userId, "dataId": dataId], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    //  {"datas":[{"userid":"1","evalid":"1"},{"userid":"3","evalid":"2"},{"userid":"2","evalid":"2"}]
    static func deleteEvaluationDatas(datas:[[String: AnyObject]], complete: ((NSError?) -> Void)) {
        
        RequestType.DeleteEvaluationDatas.startRequest(["datas" : datas], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(__FUNCTION__) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}