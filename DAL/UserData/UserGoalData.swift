//
//  UserGoalData.swift
//  Health
//
//  Created by Yalin on 15/9/5.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct UserGoalData {
    enum GoalType: Int {
        case none = 0
        case weight
        case fat
        case muscle
        
        func description() -> String {
            switch self {
            case .weight:
                return "减重"
            case .fat:
                return "减脂"
            case .muscle:
                return "增肌"
            default:
                return "未设置"
            }
        }
    }
    
    static var type: GoalType {
        get {
            if let type = UserDefaults.standard.object(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.type") as? NSNumber {
                return GoalType(rawValue: type.intValue)!
            }
            else {
                return .none
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "\(UserData.sharedInstance.userId!).UserGoalData.type")
        }
    }
    
    // 目标数量
    static var number: Int? {
        get {
            return (UserDefaults.standard.object(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.number") as? NSNumber)?.intValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.number")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "\(UserData.sharedInstance.userId!).UserGoalData.number")
            }
        }
    }
    
    // 目标天数
    static var days: Int? {
        get {
            return (UserDefaults.standard.object(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.days") as? NSNumber)?.intValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.days")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "\(UserData.sharedInstance.userId!).UserGoalData.days")
            }
        }
    }
    
    // 设置目标的时间
    static var setDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.setDate") as? Date
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "\(UserData.sharedInstance.userId!).UserGoalData.setDate")
            }
            else {
                UserDefaults.standard.set(newValue!, forKey: "\(UserData.sharedInstance.userId!).UserGoalData.setDate")
            }
        }
    }
    
    // 获取剩余天数
    static var restDays: Int? {
        let endDate = setDate?.addingTimeInterval(TimeInterval(days! * 24 * 60 * 60))
        let restTimeInterval = endDate!.timeIntervalSince(Date())
        
        if restTimeInterval < 0 {
            return 0
        }
        
        return Int(restTimeInterval / (24 * 60 * 60))
    }
}
