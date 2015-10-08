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
    
    // (userId: Int, headURLStr: String, name: String)
    func queryAllUsers() -> [(Int, String, String)] {
//        "age" : user.valueForKey("age") as! NSNumber,
//        "height" : user.valueForKey("height") as! NSNumber,
//        "name" : user.valueForKey("name") as! String,
//        "userId" : user.valueForKey("") as! NSNumber,
//        "gender" : user.valueForKey("gender") as! NSNumber,
        
        let userList = DBManager.shareInstance().queryAllUser()
        var list: [(Int, String,String)] = []
        for var i = 0; i < userList.count; i++ {
            let userInfo = userList[i]
            list.append(((userInfo["userId"] as! NSNumber).integerValue, userInfo["headURL"] as! String, userInfo["name"] as! String))
        }
        
        return list
    }
    
    func changeUserToUserId(userId: Int) {
        
    }
    
    func addUser(name: String, gender: Bool, age: UInt8, height: UInt8) {
        
    }
    
    func deleteUser(userId: Int) {
        
    }
}
