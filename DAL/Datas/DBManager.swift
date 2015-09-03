//
//  DBManager.swift
//  Health
//
//  Created by Yalin on 15/8/14.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

protocol DBUserProtocol {
    func queryAllUser() -> [[String: NSObject]]
    func addUser(setDatas:(inout setDatas: UserDBData)-> UserDBData)
    func deleteUser(userId: UInt8)
}

protocol DBManagerProtocol : DBUserProtocol {
    func addEvaluationData(setDatas:(inout setDatas: EvaluationData)-> EvaluationData)
    func deleteEvaluationData(dataId: String)
    func queryEvaluationData(dataId: String) -> EvaluationData?
    func queryEvaluationDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: NSObject]]
    
    func addGoalData(setDatas:(inout setDatas: GoalData)-> GoalData)
    func deleteGoalData(dataId: String)
    func queryGoalData(dataId: String) -> GoalData?
    
    func saveContext()
    
    var haveConnectedScale: Bool { get }
    var haveConnectedBracelet: Bool { get }
    func addDevice(uuid: String, name: String, type: Int16)
}

class DBManager {
    
    var userId: String?
    
    class func shareInstance() -> DBManager {
        struct YYSingle {
            static var predicate: dispatch_once_t = 0
            static var instance: DBManager? = nil
        }
        
        dispatch_once(&YYSingle.predicate, { () -> Void in
            YYSingle.instance = DBManager()
        })
        
        return YYSingle.instance!
    }
    
    init() {
        userId = "\(UserData.shareInstance().userId!)"
    }
}