//
//  UserManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct UserManager {
    
    // 单例
    static func shareInstance() -> UserManager {
        struct Singleton {
            static var predicate: dispatch_once_t = 0
            static var instance: UserManager? = nil
        }
        dispatch_once(&Singleton.predicate, { () -> Void in
            Singleton.instance = UserManager()
        })
        
        return Singleton.instance!
    }
    
    static var mainUser: UserModel {
        return UserModel(userId: UserData.shareInstance().userId!, age:UserData.shareInstance().age!, gender: UserData.shareInstance().gender!, height: UserData.shareInstance().height!, name: UserData.shareInstance().name!, headURL: UserData.shareInstance().headURL)
    }
    
    var currentUser: UserModel = UserManager.mainUser
    
    func changeUserToUserId(userId: Int) {
        
    }
    
    func addUser(name: String, gender: Bool, age: UInt8, height: UInt8) {
        
    }
    
    func deleteUser(userId: Int) {
        
    }
}
