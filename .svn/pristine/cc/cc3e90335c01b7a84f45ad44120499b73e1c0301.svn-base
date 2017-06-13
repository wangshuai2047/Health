//
//  UserModel.swift
//  Health
//
//  Created by Yalin on 15/9/11.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct UserModel {
    var userId: Int
    var age: UInt8
    var gender: Bool  // true为男  false为女
    var height: UInt8
    var name: String
    var headURL: String?
    
    init(info: [String : AnyObject]) {
        userId = (info["userId"] as! NSNumber).intValue
        age = (info["age"] as! NSNumber).uint8Value
        
        gender = (info["gender"] as! NSNumber).intValue == 1 ? true : false
//        gender = (info["gender"] as! NSNumber).boolValue
        height = (info["height"] as! NSNumber).uint8Value
        name = info["name"] as! String
        
        if let url = info["headURL"] as? String {
            headURL = url
        }
    }
    
    init(userId: Int, age: UInt8, gender: Bool, height: UInt8, name: String, headURL: String?) {
        self.userId = userId
        self.age = age
        self.gender = gender
        self.height = height
        self.name = name
        self.headURL = headURL
    }
}
