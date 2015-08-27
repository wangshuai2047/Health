//
//  LoginManager.swift
//  Health
//
//  Created by Yalin on 15/8/18.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct LoginManager {
    
    static var isNeedCompleteInfo: Bool {
        get {
            if UserData.shareInstance().name != nil && UserData.shareInstance().age != nil && UserData.shareInstance().gender != nil && UserData.shareInstance().height != nil {
                return false
            } else {
                return true
            }
        }
    }
    
    static var showedGUI: Bool{
        get {
        
        return false
        
            let isShowGUI = NSUserDefaults.standardUserDefaults().valueForKey("showedGUI") as? String
            if isShowGUI != nil && isShowGUI == "yes" {
                return true
            }
            else {
                return false
            }
        }
        set {
            if newValue {
                NSUserDefaults.standardUserDefaults().setValue("yes", forKey: "showedGUI")
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("showedGUI")
            }
        }
    }
    
    static var isLogin: Bool {
        get {
            
            let userData = UserData.shareInstance()
            if userData.userId != nil {
                return true
            }
            else {
                return false
            }
        }
    }
    
    static var isShowAds: Bool {
        get {
            return false
        }
    }
    
    // 通过手机号 和 验证码登录
    static func login(phone: String, captchas: String, complete: ((NSError?) -> Void)?) {
        
        LoginRequest.login(phone, password: captchas) { (userInfo: [String: AnyObject]?, error: NSError?) -> Void in
            // deal userInfo
            if error == nil {
                var userId: NSNumber = userInfo!["userId"] as! NSNumber
                UserData.shareInstance().userId = userId.unsignedCharValue
                UserData.shareInstance().phone = phone
            }
            
            if complete != nil {
                complete!(error)
            }
        }
    }
    
    // 获取验证码
    static func queryCaptchas(phone: String, complete: ((String?, NSError?) -> Void)?) {
        LoginRequest.queryCaptchas(phone, complete: { (captchas: String?, error: NSError?) -> Void in
            
            if complete != nil {
                complete!(captchas,error)
            }
        })
    }
    
    // 获取登录广告
    static func queryLoginAds(complete: ((ads: [LoginAdModel], error: NSError?) -> Void)?) {
        AdsRequest.queryLoginAds { (ads, error) -> Void in
            if complete != nil {
                complete!(ads: ads, error: error)
            }
        }
    }
    
    // 完善信息
    static func completeInfomation(name: String, gender: UInt8, age: UInt8, height: UInt8, phone: String?, organizationCode: String?, complete: ((error: NSError?) -> Void)) {
        
        if UserData.shareInstance().userId == nil {
            complete(error: NSError(domain: "\(__FUNCTION__)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
        
        UserRequest.completeUserInfo(UserData.shareInstance().userId!, gender: gender, height: height, age: age, name: name, phone: phone, organizationCode: organizationCode) { (error) -> Void in
            
            if error == nil {
                UserData.shareInstance().name = name
                UserData.shareInstance().gender = gender
                UserData.shareInstance().age = age
                UserData.shareInstance().height = height
                
                UserData.shareInstance().phone = phone
                UserData.shareInstance().organizationCode = organizationCode
            }
            
            complete(error: error)
        }
    }
    
    static func uploadHeadIcon(imageURL: NSURL, complete: ((error: NSError?) -> Void)) {
        if UserData.shareInstance().userId == nil {
            complete(error: NSError(domain: "\(__FUNCTION__)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
        
        UserRequest.uploadHeadIcon(UserData.shareInstance().userId!, imageURL: imageURL, complete: complete)
    }
    
    // 登出
    static func logout() {
        UserData.shareInstance().clearDatas()
    }
    
    
    // 初始化ShareSDK
    static func initShareSDK() {
        ShareSDKHelper.initSDK()
    }
    
    // 通过QQ登录
    static func loginWithQQ(complete: ((NSError?) -> Void)?) {
        ShareSDKHelper.loginWithQQ { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            

            if complete != nil {
                complete!(error)
            }
        }
    }
    
    // 通过WeChat登录
    static func loginWithWeChat(complete: ((NSError?) -> Void)?) {
        ShareSDKHelper.loginWithWeChat { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            
            if complete != nil {
                complete!(error)
            }
        }
    }
    
    // 通过WeiBo登录
    static func loginWithWeiBo(complete: ((NSError?) -> Void)?) {
        ShareSDKHelper.loginWithWeiBo { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            

            if complete != nil {
                complete!(error)
            }
        }
    }
}
