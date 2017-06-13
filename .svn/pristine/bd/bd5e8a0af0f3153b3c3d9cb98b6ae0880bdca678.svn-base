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
    static func queryEvaluationDatas(_ userId: Int, startDate: Date, endDate: Date, complete : @escaping ((_ datas: [[String: AnyObject]]? , NSError?) -> Void)) {
        RequestType.QueryEvaluationDatas.startRequest(["userId": userId as AnyObject, "startTimestamp" : startDate.secondTimeInteval() as AnyObject, "endTimestamp" : endDate.secondTimeInteval() as AnyObject], completionHandler: { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?.value(forKey: "datas") as? [[String: AnyObject]], nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    // 上传评测数据
    static func uploadEvaluationDatas(_ pid: Int, datas: [[String: AnyObject]]? , complete: @escaping ((_ info: [[String: AnyObject]]?, NSError?) -> Void)) {
        
        RequestType.UploadEvaluationDatas.startRequest(["datas": datas! as AnyObject, "pid": pid as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?.value(forKey: "info") as? [[String: AnyObject]], nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    static func deleteEvaluationData(_ dataId: String, userId: Int, complete: @escaping ((NSError?) -> Void)) {
        RequestType.DeleteEvaluationData.startRequest(["userId": userId as AnyObject, "dataId": dataId as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
    
    //  {"datas":[{"userid":"1","evalid":"1"},{"userid":"3","evalid":"2"},{"userid":"2","evalid":"2"}]
    static func deleteEvaluationDatas(_ datas:[[String: AnyObject]], complete: @escaping ((NSError?) -> Void)) {
        
        RequestType.DeleteEvaluationDatas.startRequest(["datas" : datas as AnyObject], completionHandler: { (data, response, error) -> Void in
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        })
    }
}
