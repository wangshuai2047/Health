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
        case None = 0
        case Weight
        case Fat
        case Muscle
        
        func description() -> String {
            switch self {
            case .Weight:
                return "减重"
            case .Fat:
                return "减脂"
            case .Muscle:
                return "增肌"
            default:
                return "未设置"
            }
        }
    }
    
    static var type: GoalType {
        get {
            if let type = NSUserDefaults.standardUserDefaults().objectForKey("\(UserData.shareInstance().userId!).UserGoalData.type") as? NSNumber {
                return GoalType(rawValue: type.integerValue)!
            }
            else {
                return .None
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue.rawValue, forKey: "\(UserData.shareInstance().userId!).UserGoalData.type")
        }
    }
    
    // 目标数量
    static var number: Int? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("\(UserData.shareInstance().userId!).UserGoalData.number") as? NSNumber)?.integerValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("\(UserData.shareInstance().userId!).UserGoalData.number")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "\(UserData.shareInstance().userId!).UserGoalData.number")
            }
        }
    }
    
    // 目标天数
    static var days: Int? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("\(UserData.shareInstance().userId!).UserGoalData.days") as? NSNumber)?.integerValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("\(UserData.shareInstance().userId!).UserGoalData.days")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "\(UserData.shareInstance().userId!).UserGoalData.days")
            }
        }
    }
    
    // 设置目标的时间
    static var setDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("\(UserData.shareInstance().userId!).UserGoalData.setDate") as? NSDate
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("\(UserData.shareInstance().userId!).UserGoalData.setDate")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: "\(UserData.shareInstance().userId!).UserGoalData.setDate")
            }
        }
    }
    
    // 获取剩余天数
    static var restDays: Int? {
        let endDate = setDate?.dateByAddingTimeInterval(NSTimeInterval(days! * 24 * 60 * 60))
        let restTimeInterval = NSDate().timeIntervalSinceDate(endDate!)
        
        return Int(restTimeInterval / (24 * 60 * 60))
    }
}