//
//  GoalRequest.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct GoalRequest {
    
    // 上传设置目标数据  "userId":149,"type":2,"number":100,"days":13,"setDate":1451833727}
    static func uploadSettingGoalDatas(_ userId: Int, type: Int, number: Int, days: Int, setDate: Date, complete: @escaping (NSError?) -> Void) {
        RequestType.UploadSettingGoalDatas.startRequest(["userId" : userId as AnyObject, "type": type as AnyObject, "number" : number as AnyObject, "days" : days as AnyObject, "setDate" : setDate.secondTimeInteval() as AnyObject]) { (data, response, error) -> Void in
            
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
        }
    }
    
    // 获取设置目标数据
    static func querySettingGoalDatas(_ userId: Int, complete: @escaping (_ datas: [String: AnyObject]?, NSError?) -> Void) {
        RequestType.QuerySettingGoalDatas.startRequest(["userId" : userId as AnyObject]) { (data, response, error) -> Void in
            
            let result = Request.dealResponseData(data, response: response, error: error)
            if let err = result.error {
                complete(nil, err)
                #if DEBUG
                    println("\n----------\n\(#function) \nerror:\(err.localizedDescription)\n==========")
                #endif
            }
            else {
                let jsonObj: NSDictionary? = result.jsonObj as? NSDictionary
                complete(jsonObj?.value(forKey: "info") as? [String: AnyObject], nil)
                #if DEBUG
                    println("\n----------\n\(#function) \nresult \(jsonObj)\n==========")
                #endif
            }
        }
    }
    
    // 获取目标数据
    static func queryGoalDatas(_ userId: Int, startDate: Date, endDate: Date, complete : @escaping ((_ datas: [[String: AnyObject]]? , NSError?) -> Void)) {
        RequestType.QueryGoalDatas.startRequest(["userId": userId as AnyObject, "startTimestamp" : startDate.secondTimeInteval() as AnyObject, "endTimestamp" : endDate.secondTimeInteval() as AnyObject], completionHandler: { (data, response, error) -> Void in
            
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
    static func uploadGoalDatas(_ datas: [[String: AnyObject]]? , complete: @escaping ((_ info: [[String: AnyObject]]?, NSError?) -> Void)) {
        
//        let jsonStr = NSString(data: NSJSONSerialization.dataWithJSONObject(datas!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!, encoding: NSUTF8StringEncoding)
        
        RequestType.UploadGoalDatas.startRequest(["datas": datas! as AnyObject], completionHandler: { (data, response, error) -> Void in
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
    
    static func deleteGoalData(_ dataId: String, userId: Int, complete: @escaping ((NSError?) -> Void)) {
        RequestType.DeleteGoalData.startRequest(["userId": userId as AnyObject, "dataId": dataId as AnyObject], completionHandler: { (data, response, error) -> Void in
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
    static func deleteGoalDatas(_ datas:[[String: AnyObject]], complete: @escaping ((NSError?) -> Void)) {
        
        RequestType.DeleteGoalDatas.startRequest(["datas" : datas as AnyObject], completionHandler: { (data, response, error) -> Void in
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
