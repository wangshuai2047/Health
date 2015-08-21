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

    var userId: UInt8?
    var gender: UInt8?
    var height: UInt8?
    var weight: Int?
    var name: String?
    var age: UInt8?
    var phone: String?
    var organizationCode: String?
    var head: NSData?
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
}