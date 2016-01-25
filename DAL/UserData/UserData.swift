//
//  UserData.swift
//  Health
//
//  Created by Yalin on 15/8/15.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

// 储存类 必须是class
class UserData {

    var userId: Int? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.userId") as? NSNumber)?.integerValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserData.userId")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "UserData.userId")
            }
        }
    }
    
    var gender: Bool? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.gender") as? NSNumber)?.boolValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserData.gender")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Bool(newValue!), forKey: "UserData.gender")
            }
        }
    }
    
    var height: UInt8? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.height") as? NSNumber)?.unsignedCharValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserData.height")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "UserData.height")
            }
        }
    }
    
    var weight: Int? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.weight") as? NSNumber)?.integerValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserData.weight")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "UserData.weight")
            }
        }
    }
    
    var name: String? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.name") as? String)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "UserData.name")
        }
    }
    
    var age: UInt8? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.age") as? NSNumber)?.unsignedCharValue
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserData.age")
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(Int(newValue!), forKey: "UserData.age")
            }
        }
    }
    
    var phone: String? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.phone") as? String)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "UserData.phone")
        }
    }
    
    var organizationCode: String? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.organizationCode") as? String)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "UserData.organizationCode")
        }
    }
    
    var headURL: String? {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey("UserData.headURL") as? String)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "UserData.headURL")
        }
    }
    
    var isBindQQ: Bool?
    var isBindWeChat: Bool?
    var isBindWeiBo: Bool?
    
    static func shareInstance() -> UserData {
        struct YYSingle {
            static var predicate: dispatch_once_t = 0
            static var instance: UserData? = nil
        }
        
        dispatch_once(&YYSingle.predicate, { () -> Void in
            YYSingle.instance = UserData()
        })
        
        return YYSingle.instance!
    }
    
    func clearDatas() {
        self.userId = nil
        self.gender = nil
        self.height = nil
        self.weight = nil
        self.name = nil
        self.age = nil
        self.phone = nil
        self.organizationCode = nil
        self.headURL = nil
        
        DBManager.shareInstance().deleteAllUser()
    }
    
}