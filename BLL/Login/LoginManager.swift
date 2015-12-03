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
            let isShowGUI = NSUserDefaults.standardUserDefaults().valueForKey("showedGUI") as? String
            if isShowGUI != nil && isShowGUI == "yes" {
                return false
            }
            else {
                return true
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
    static func login(phone: String?, captchas: String?, complete: ((NSError?) -> Void)?) {
        
        if phone == nil || captchas == nil || captchas == "" || phone == ""{
            complete?(NSError(domain: "登录", code: 0, userInfo: [NSLocalizedDescriptionKey:"手机号或验证码不能为空"]))
            return
        }
        
        LoginRequest.login(phone!, captchas: captchas!) { (userInfo: [String: AnyObject]?, error: NSError?) -> Void in
            // deal userInfo
            if error == nil {
                parseUserInfo(userInfo!)
            }
            complete?(error)
        }
    }
    
    // 获取验证码
    static func queryCaptchas(phone: String?, complete: ((String?, NSError?) -> Void)?) {
        
        if phone == nil || phone == "" {
            complete?("", NSError(domain: "获取验证码", code: 0, userInfo: [NSLocalizedDescriptionKey:"手机号不能为空"]))
            return
        }
        
        LoginRequest.queryCaptchas(phone!, complete: { (authCode: String?, error: NSError?) -> Void in
            complete?(authCode,error)
        })
    }
    
    // 获取登录广告
    static func queryLoginAds(complete: ((ad: RequestLoginAdModel?, error: NSError?) -> Void)?) {
        AdsRequest.queryLaunchAds { (ad, error) -> Void in
            complete?(ad: ad, error: error)
        }
    }
    
    // 完善信息
    static func completeInfomation(name: String, gender: Bool, age: UInt8, height: UInt8, phone: String?, organizationCode: String?, headURL: String?, complete: ((error: NSError?) -> Void)) {
        
        if UserData.shareInstance().userId == nil {
            complete(error: NSError(domain: "\(__FUNCTION__)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
        
        UserRequest.completeUserInfo(Int(UserData.shareInstance().userId!), gender: gender, height: height, age: age, name: name, phone: phone, organizationCode: organizationCode, imageURL: headURL) { (imageURLStr, error) -> Void in
            
            if headURL != nil {
                _ = try? NSFileManager.defaultManager().removeItemAtPath(headURL!)
            }
            
            
            if error == nil {
                UserData.shareInstance().name = name
                UserData.shareInstance().gender = gender
                UserData.shareInstance().age = age
                UserData.shareInstance().height = height
                
                UserData.shareInstance().phone = phone
                UserData.shareInstance().organizationCode = organizationCode
                
                UserData.shareInstance().headURL = imageURLStr
            }
            
            complete(error: error)
        }
    }
    
    static func uploadHeadIcon(imageURL: NSURL, complete: ((error: NSError?) -> Void)) {
        if UserData.shareInstance().userId == nil {
            complete(error: NSError(domain: "\(__FUNCTION__)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
    }
    
    // 登出
    static func logout() {
        
        bindQQOpenId = nil
        bindWeiBoOpenId = nil
        bindWeChatOpenId = nil
        UserData.shareInstance().clearDatas()
    }
    
    
    // 初始化ShareSDK
    static func initShareSDK() {
        ShareSDKHelper.initSDK()
    }
    
    static func isExistShareApp(shareType: ShareType) -> Bool {
        return ShareSDKHelper.isExistShareType(shareType)
    }
    
    // MARK: - 第三方方法
    // 通过QQ登录
    static func loginWithQQ(complete: ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithQQ { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.QQ, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    // 通过WeChat登录
    static func loginWithWeChat(complete: ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithWeChat { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.WeChat, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    // 通过WeiBo登录
    static func loginWithWeiBo(complete: ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithWeiBo { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.Weibo, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    static func loginThirdPlatform(type: ThirdPlatformType, complete: (name: String?, headURLStr: String?, error: NSError?) -> Void) {
        
        func dealLoginFinished(uid: String?, name: String?, headIcon: String?, error: NSError?) {
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: type) { (error: NSError?) -> Void in
                    complete(name: name, headURLStr: headIcon, error: error)
                }
            }
            else {
                complete(name: nil, headURLStr: nil, error: error)
            }
        }
        
        switch type {
        case .QQ:
            ShareSDKHelper.loginWithQQ({ (uid, name, headIcon, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, error: error)
            })
        case .WeChat:
            ShareSDKHelper.loginWithWeChat({ (uid, name, headIcon, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, error: error)
            })
        case .Weibo:
            ShareSDKHelper.loginWithWeiBo({ (uid, name, headIcon, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, error: error)
            })
        }
    }
    
    static func loginThirdParty(name: String, headURLStr: String, openId: String, type: ThirdPlatformType, complete: ((NSError?) -> Void) ) {
        LoginRequest.loginThirdPlatform(name, headURLStr: headURLStr, openId: openId, type: type) { (userInfo, error: NSError?) -> Void in
            
            if error == nil {
                parseUserInfo(userInfo!)
            }
            else {
                
                var shareType: ShareType?
                if type == .WeChat {
                    shareType = ShareType.WeChatSession
                }
                else if type == .Weibo {
                    shareType = ShareType.WeiBo
                }
                else if type == .QQ {
                    shareType = ShareType.QQFriend
                }
                ShareSDKHelper.cancelBind(shareType!)
            }
            complete(error)
            
        }
    }
    
    // MARK: - bind
    static private var bindQQOpenId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("isBindQQ") as? String
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "isBindQQ")
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("isBindQQ")
            }
        }
    }
    
    static private var bindWeChatOpenId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("isBindWeChat") as? String
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "isBindWeChat")
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("isBindWeChat")
            }
        }
    }
    
    static private var bindWeiBoOpenId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("isBindWeiBo") as? String
        }
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "isBindWeiBo")
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("isBindWeiBo")
            }
        }
    }
    
    static func bindThirdParty(type: ThirdPlatformType, complete: (NSError?) -> Void) {
        
        func serverBind(openId: String?, type: ThirdPlatformType) {
            LoginRequest.bindThirdPlatform(UserData.shareInstance().userId!, openId: openId!, type: type) { (error: NSError?) -> Void in
                if error == nil {
                    if type == ThirdPlatformType.QQ {
                        bindQQOpenId = openId
                    }
                    else if type == ThirdPlatformType.WeChat {
                        bindWeChatOpenId = openId
                    }
                    else if type == ThirdPlatformType.Weibo {
                        bindWeiBoOpenId = openId
                    }
                    complete(nil)
                }
                else {
                    complete(error)
                    ShareSDKHelper.cancelBind(ShareType(type: type))
                }
            }
        }
        
        if type == ThirdPlatformType.QQ {
            ShareSDKHelper.loginWithQQ({ (uid, name, headIcon, error) -> Void in
                if error == nil {
                    serverBind(uid, type: type)
                }
                else {
                    complete(error)
                }
            })
        }
        else if type == ThirdPlatformType.Weibo {
            ShareSDKHelper.loginWithWeiBo({ (uid, name, headIcon, error) -> Void in
                if error == nil {
                    serverBind(uid, type: type)
                }
                else {
                    complete(error)
                }
            })
        }
        else {
            ShareSDKHelper.loginWithWeChat({ (uid, name, headIcon, error) -> Void in
                if error == nil {
                    serverBind(uid, type: type)
                }
                else {
                    complete(error)
                }
            })
        }
    }
    
    static func cancelBindThirdParty(type: ThirdPlatformType, complete: (NSError?) -> Void) {
        
        var openId: String = ""
        if type == ThirdPlatformType.QQ {
            openId = bindQQOpenId!
        }
        else if type == ThirdPlatformType.WeChat {
            openId = bindWeChatOpenId!
        }
        else if type == ThirdPlatformType.Weibo {
            openId = bindWeiBoOpenId!
        }
        
        LoginRequest.cancelBindThirdPlatform(UserData.shareInstance().userId!, openId: openId, type: type) { (error: NSError?) -> Void in
            if error == nil {
                if type == ThirdPlatformType.QQ {
                    bindQQOpenId = nil
                }
                else if type == ThirdPlatformType.WeChat {
                    bindWeChatOpenId = nil
                }
                else if type == ThirdPlatformType.Weibo {
                    bindWeiBoOpenId = nil
                }
            }
            complete(error)
        }
        ShareSDKHelper.cancelBind(ShareType(type: type))
    }
    
    static func isBindThirdParty(type: ThirdPlatformType) -> Bool {
        if type == .WeChat {
            if bindWeChatOpenId != nil {
                return true
            }
        }
        else if type == .Weibo {
            if bindWeiBoOpenId != nil {
                return true
            }
        }
        else if type == .QQ {
            if bindQQOpenId != nil {
                return true
            }
        }
        return false
    }
    
    static func parseUserInfo(userInfo: [String: AnyObject]) {
        
        if let userId = userInfo["userid"] as? String {
            print("userId\(userId)")
            UserData.shareInstance().userId = NSString(string: userId).integerValue
            
        }
        
        if let userId = userInfo["userid"] as? NSNumber {
            print("userId\(userId)")
            UserData.shareInstance().userId = userId.integerValue
            
        }
        
        if let userId = userInfo["userId"] as? NSNumber {
            print("userId\(userId)")
            UserData.shareInstance().userId = userId.integerValue
        }
        
        if let phone = userInfo["mobile"] as? String {
            print("mobile\(phone)")
            UserData.shareInstance().phone = phone
        }
        
        if let age = userInfo["age"] as? NSNumber {
            print("age\(age)")
            UserData.shareInstance().age = age.unsignedCharValue
        }
        
        if let gender = userInfo["gender"] as? NSNumber {
            print("gender\(gender)")
            UserData.shareInstance().gender = gender.integerValue == 1 ? true : false
        }
        
        if let head = userInfo["headURL"] as? String {
            print("head\(head)")
            UserData.shareInstance().headURL = head
        }
        
        if let height = userInfo["height"] as? NSNumber {
            print("height\(height)")
            UserData.shareInstance().height = height.unsignedCharValue
        }
        
        if let name = userInfo["name"] as? String {
            print("name\(name)")
            UserData.shareInstance().name = name
        }
        
        if let organizationCode = userInfo["organizationCode"] as? String {
            print("organizationCode\(organizationCode)")
            UserData.shareInstance().organizationCode = organizationCode
        }
        
        if let childs = userInfo["child"] as? [[String : AnyObject]] {
            DBManager.shareInstance().deleteAllUser()
            for info in childs {
                let userModel = UserModel(info: info)
                DBManager.shareInstance().addOrUpdateUser(userModel)
            }
        }
        
        // 如果不需要完善信息
        if !LoginManager.isNeedCompleteInfo {
            UserManager.shareInstance().currentUser = UserManager.mainUser
        }
        
        // 第三方绑定
        bindQQOpenId = nil
        bindWeiBoOpenId = nil
        bindWeChatOpenId = nil
        if let apps = userInfo["app"] as? [[String : AnyObject]] {
            for app in apps {
                let openId = app["openId"] as? String
                if let type = app["type"] as? String {
                    if type == ThirdPlatformType.QQ.rawValue {
                        bindQQOpenId = openId
                    }
                    else if type == ThirdPlatformType.WeChat.rawValue {
                        bindWeChatOpenId = openId
                    }
                    else if type == ThirdPlatformType.Weibo.rawValue {
                        bindWeiBoOpenId = openId
                    }
                }
            }
        }
    }
}
