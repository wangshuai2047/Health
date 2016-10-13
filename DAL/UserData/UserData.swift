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

    static let sharedInstance = UserData()

    var userId: Int? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.userId") as? NSNumber)?.intValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "UserData.userId")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "UserData.userId")
            }
        }
    }
    
    var gender: Bool? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.gender") as? NSNumber)?.boolValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "UserData.gender")
            }
            else {
                UserDefaults.standard.set(Bool(newValue!), forKey: "UserData.gender")
            }
        }
    }
    
    var height: UInt8? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.height") as? NSNumber)?.uint8Value
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "UserData.height")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "UserData.height")
            }
        }
    }
    
    var weight: Int? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.weight") as? NSNumber)?.intValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "UserData.weight")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "UserData.weight")
            }
        }
    }
    
    var name: String? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.name") as? String)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserData.name")
        }
    }
    
    var age: UInt8? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.age") as? NSNumber)?.uint8Value
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "UserData.age")
            }
            else {
                UserDefaults.standard.set(Int(newValue!), forKey: "UserData.age")
            }
        }
    }
    
    var phone: String? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.phone") as? String)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserData.phone")
        }
    }
    
    var organizationCode: String? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.organizationCode") as? String)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserData.organizationCode")
        }
    }
    
    var headURL: String? {
        get {
            return (UserDefaults.standard.object(forKey: "UserData.headURL") as? String)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserData.headURL")
        }
    }
    
    var isBindQQ: Bool?
    var isBindWeChat: Bool?
    var isBindWeiBo: Bool?
    
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
        
        DBManager.sharedInstance.deleteAllUser()
    }
    
}
