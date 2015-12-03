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
        userId = (info["userId"] as! NSNumber).integerValue
        age = (info["age"] as! NSNumber).unsignedCharValue
        
        gender = (info["gender"] as! NSNumber).integerValue == 1 ? true : false
//        gender = (info["gender"] as! NSNumber).boolValue
        height = (info["height"] as! NSNumber).unsignedCharValue
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
