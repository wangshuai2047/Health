//
//  DBManager.swift
//  Health
//
//  Created by Yalin on 15/8/14.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

protocol DBManagerProtocol {
    func addEvaluationData(setDatas:(inout setDatas: EvaluationData)-> EvaluationData)
    func deleteEvaluationData(dataId: String)
    func queryEvaluationData(dataId: String) -> EvaluationData?
    
    func addGoalData(setDatas:(inout setDatas: GoalData)-> GoalData)
    func deleteGoalData(dataId: String)
    func queryGoalData(dataId: String) -> GoalData?
    
    func saveContext()
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
}