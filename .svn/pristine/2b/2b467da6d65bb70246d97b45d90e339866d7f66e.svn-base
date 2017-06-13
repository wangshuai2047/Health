//
//  DBManager.swift
//  Health
//
//  Created by Yalin on 15/8/14.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

protocol DBUserProtocol {
    func queryAllUser() -> [[String: AnyObject]]
    func addUser(_ setDatas:( _ setDatas: inout UserDBData)-> UserDBData)
    func addOrUpdateUser(_ userModel: UserModel)
    func deleteUser(_ userId: Int)
    func queryUser(_ userId: Int) -> [String: AnyObject]?
    func deleteAllUser()
}

protocol DBEvaluationProtocol {
    
    func addEvaluationData(_ result: ScaleResultProtocol)
    func deleteEvaluationData(_ dataId: String, userId: Int)
    func queryEvaluationData(_ dataId: String, userId: Int) -> [String: AnyObject]?
    func queryEvaluationDatas(_ beginTimescamp: Date, endTimescamp: Date, userId: Int) -> [[String: AnyObject]]
    func queryNoUploadEvaluationDatas() -> [[String: AnyObject]]
    func updateUploadEvaluationDatas(_ newDataIdInfos: [[String: AnyObject]])
    func queryLastEvaluationData(_ userId: Int) -> [String: AnyObject]?
    func queryCountEvaluationDatas(_ beginTimescamp: Date, endTimescamp: Date, userId: Int, count: Int) -> [[String: AnyObject]]
}

protocol DBGoalProtocol {
    func addGoalDatas(_ data: BraceletResultProtocol)
    func deleteGoalData(_ dataId: String)
    func deleteGoalDatas(_ date: Date)
    func queryGoalData(_ dataId: String) -> [String: AnyObject]?
    func queryLastGoalData() -> [String: AnyObject]?
    func queryGoalData(_ beginDate: Date, endDate: Date) -> [[String: AnyObject]]
    func queryNoUploadGoalDatas() -> [[String: AnyObject]]
    func updateUploadGoalDatas(_ newDataIdInfos: [[String: AnyObject]])
}

protocol DBDeviceProtocol {
    func removeDeviceBind(_ type: DeviceType)
    func haveConnectedWithType(_ type: DeviceType) -> Bool
    var haveConnectedScale: Bool { get }
    var haveConnectedBracelet: Bool { get }
    func braceletInfo() -> (uuid: String, name: String)?
    func myBodyInfo() -> (uuid: String, name: String)?
    func addDevice(_ uuid: String, name: String, type: DeviceType)
}

protocol DBShareProtocol {
    func addShareData(_ type: Int)
    func queryShareDatas(_ beginDate: Date, endDate: Date) -> [[String: AnyObject]]
}

protocol DBManagerProtocol : DBUserProtocol, DBEvaluationProtocol, DBGoalProtocol, DBDeviceProtocol, DBShareProtocol {
    func saveContext()
}

class DBManager {
    
    var userId: String?
    static let sharedInstance = DBManager()
    
    init() {
        userId = "\(UserData.sharedInstance.userId!)"
    }
}
