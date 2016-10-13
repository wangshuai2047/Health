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
    static let sharedInstance = UserManager()
    
    static var mainUser: UserModel {
        return UserModel(userId: UserData.sharedInstance.userId!, age:UserData.sharedInstance.age!, gender: UserData.sharedInstance.gender!, height: UserData.sharedInstance.height!, name: UserData.sharedInstance.name!, headURL: UserData.sharedInstance.headURL)
    }
    
    var currentUser: UserModel = UserManager.mainUser
    
//    func userHeadURL(headURLString: String) -> String {
//        return Request.requestPHPPathURL() + headURLString
//    }
    
    // (userId: Int, headURLStr: String, name: String)
    func queryAllUsers() -> [(Int, String, String)] {
        
        let userList = DBManager.sharedInstance.queryAllUser()
        var list: [(Int, String,String)] = []
        
        if userList.count > 0 {
            for i in 0...userList.count-1 {
                let userInfo = userList[i]
                let headURL = userInfo["headURL"] as! String
                list.append(((userInfo["userId"] as! NSNumber).intValue, headURL, userInfo["name"] as! String))
            }
        }
        
        // 把自己添加上
        list.insert((UserManager.mainUser.userId, UserManager.mainUser.headURL == nil ? "" : UserManager.mainUser.headURL!, UserManager.mainUser.name), at: 0)
        
        return list
    }
    
    func changeUserToUserId(_ userId: Int) {
        if userId == UserData.sharedInstance.userId! {
            currentUser = UserManager.mainUser
        }
        else {
            if let info = DBManager.sharedInstance.queryUser(userId) {
                currentUser = UserModel(info: info)
            }
            
        }
    }
    
    func addUser(_ name: String, gender: Bool, age: UInt8, height: UInt8, imageURL: String?, complete: @escaping ((_ userModel: UserModel?, NSError?) -> Void)) {
        
        UserRequest.createUser(UserData.sharedInstance.userId!, name: name, height: Int(height), age: Int(age), gender: gender, imageURL: imageURL) { (userId, headURL, error: NSError?) -> Void in
            var userModel: UserModel? = nil
            if error == nil {
                
                if imageURL != nil {
                    _ = try? FileManager.default.removeItem(atPath: imageURL!)
                }
                
                userModel = UserModel(userId: userId!, age: age, gender: gender, height: height, name: name, headURL: headURL)
                // { (inout setDatas: EvaluationData) -> EvaluationData in
                DBManager.sharedInstance.addUser({ (setDatas: inout UserDBData) -> UserDBData in
                    setDatas.userId = NSNumber(value: userModel!.userId as Int)
                    setDatas.age = NSNumber(value: age as UInt8)
                    setDatas.height = NSNumber(value: height as UInt8)
                    setDatas.gender = NSNumber(value: gender as Bool)
                    setDatas.name = name
                    if headURL != nil {
                        setDatas.headURL = headURL!
                    }
                    
                    return setDatas
                })
            }
            complete(userModel, error)
        }
    }
    
    func deleteUser(_ userId: Int, complete: @escaping (NSError?) -> Void) {
        UserRequest.deleteUser(UserData.sharedInstance.userId!, userId: userId) { [unowned self] (error: NSError?) -> Void in
            if error == nil {
                DBManager.sharedInstance.deleteUser(userId)
                if self.currentUser.userId == userId {
                    self.changeUserToUserId(UserManager.mainUser.userId)
                }
            }
            complete(error)
        }
    }
    
    func queryUser(_ userId: Int) -> UserModel? {
        if let info = DBManager.sharedInstance.queryUser(userId) {
            return UserModel(info: info)
        }
        return nil
    }
    
    func changeUserInfo(_ user: UserModel, phone: String?, organizationCode: String?, complete: @escaping (NSError?) -> Void) {
        UserRequest.completeUserInfo(user.userId, gender: user.gender, height: user.height, age: user.age, name: user.name, phone: phone, organizationCode: organizationCode, imageURL: user.headURL) { (imageURL, error) -> Void in
            if error == nil {
                
                if user.headURL != nil {
                    _ = try? FileManager.default.removeItem(atPath: user.headURL!)
                }
                
                var dbUser = user
                dbUser.headURL = imageURL
                
                if user.userId != UserManager.mainUser.userId {
                    DBManager.sharedInstance.addOrUpdateUser(dbUser)
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
