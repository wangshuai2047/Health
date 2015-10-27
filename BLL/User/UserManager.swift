//
//  UserManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

class UserManager {
    
    // 单例
    class func shareInstance() -> UserManager {
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
    
//    func userHeadURL(headURLString: String) -> String {
//        return Request.requestPHPPathURL() + headURLString
//    }
    
    // (userId: Int, headURLStr: String, name: String)
    func queryAllUsers() -> [(Int, String, String)] {
        
        let userList = DBManager.shareInstance().queryAllUser()
        var list: [(Int, String,String)] = []
        for var i = 0; i < userList.count; i++ {
            let userInfo = userList[i]
            let headURL = userInfo["headURL"] as! String
            list.append(((userInfo["userId"] as! NSNumber).integerValue, headURL, userInfo["name"] as! String))
        }
        
        // 把自己添加上
        list.insert((UserManager.mainUser.userId, UserManager.mainUser.headURL == nil ? "" : UserManager.mainUser.headURL!, UserManager.mainUser.name), atIndex: 0)
        
        return list
    }
    
    func changeUserToUserId(userId: Int) {
        if userId == UserData.shareInstance().userId! {
            currentUser = UserManager.mainUser
        }
        else {
            if let info = DBManager.shareInstance().queryUser(userId) {
                currentUser = UserModel(info: info)
            }
            
        }
    }
    
    func addUser(name: String, gender: Bool, age: UInt8, height: UInt8, imageURL: String?, complete: ((userModel: UserModel?, NSError?) -> Void)) {
        
        UserRequest.createUser(UserData.shareInstance().userId!, name: name, height: Int(height), age: Int(age), gender: gender, imageURL: imageURL) { (userId, headURL, error: NSError?) -> Void in
            var userModel: UserModel? = nil
            if error == nil {
                
                if imageURL != nil {
                    _ = try? NSFileManager.defaultManager().removeItemAtPath(imageURL!)
                }
                
                userModel = UserModel(userId: userId!, age: age, gender: gender, height: height, name: name, headURL: headURL)
                // { (inout setDatas: EvaluationData) -> EvaluationData in
                DBManager.shareInstance().addUser({ (inout setDatas: UserDBData) -> UserDBData in
                    setDatas.userId = NSNumber(integer: userModel!.userId)
                    setDatas.age = NSNumber(unsignedChar: age)
                    setDatas.height = NSNumber(unsignedChar: height)
                    setDatas.gender = NSNumber(bool: gender)
                    setDatas.name = name
                    if headURL != nil {
                        setDatas.headURL = headURL!
                    }
                    
                    return setDatas
                })
            }
            complete(userModel: userModel, error)
        }
    }
    
    func deleteUser(userId: Int, complete: (NSError?) -> Void) {
        UserRequest.deleteUser(UserData.shareInstance().userId!, userId: userId) { [unowned self] (error: NSError?) -> Void in
            if error == nil {
                DBManager.shareInstance().deleteUser(userId)
                if self.currentUser.userId == userId {
                    self.changeUserToUserId(UserManager.mainUser.userId)
                }
            }
            complete(error)
        }
    }
    
    func queryUser(userId: Int) -> UserModel? {
        if let info = DBManager.shareInstance().queryUser(userId) {
            return UserModel(info: info)
        }
        return nil
    }
    
    func changeUserInfo(user: UserModel,  complete: (NSError?) -> Void) {
        UserRequest.completeUserInfo(user.userId, gender: user.gender, height: user.height, age: user.age, name: user.name, phone: nil, organizationCode: nil, imageURL: user.headURL) { (imageURL, error) -> Void in
            if error == nil {
                
                if user.headURL != nil {
                    _ = try? NSFileManager.defaultManager().removeItemAtPath(user.headURL!)
                }
                
                var dbUser = user
                dbUser.headURL = imageURL
                
                if user.userId != UserManager.mainUser.userId {
                    DBManager.shareInstance().addOrUpdateUser(dbUser)
                }
            }
            complete(error)
        }
    }
}

extension UserModel {
    var serverHeadURLStr: String {
        if self.headURL == nil {
            return ""
        }
        return Request.requestPHPPathURL() + self.headURL!
    }
}
