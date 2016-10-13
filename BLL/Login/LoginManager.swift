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
            if UserData.sharedInstance.name != nil && UserData.sharedInstance.age != nil && UserData.sharedInstance.gender != nil && UserData.sharedInstance.height != nil {
                return false
            } else {
                return true
            }
        }
    }
    
    static var showedGUI: Bool{
        get {
            let isShowGUI = UserDefaults.standard.value(forKey: "showedGUI") as? String
            if isShowGUI != nil && isShowGUI == "yes" {
                return false
            }
            else {
                return true
            }
        }
        set {
            if newValue {
                UserDefaults.standard.setValue("yes", forKey: "showedGUI")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "showedGUI")
            }
        }
    }
    
    static var isLogin: Bool {
        get {
            
            let userData = UserData.sharedInstance
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
    static func login(_ phone: String?, captchas: String?, complete: ((NSError?) -> Void)?) {
        
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
    static func queryCaptchas(_ phone: String?, complete: ((String?, NSError?) -> Void)?) {
        
        if phone == nil || phone == "" {
            complete?("", NSError(domain: "获取验证码", code: 0, userInfo: [NSLocalizedDescriptionKey:"手机号不能为空"]))
            return
        }
        
        LoginRequest.queryCaptchas(phone!, complete: { (authCode: String?, error: NSError?) -> Void in
            complete?(authCode,error)
        })
    }
    
    // 获取登录广告
    static func queryLoginAds(_ complete: ((_ ad: RequestLoginAdModel?, _ error: NSError?) -> Void)?) {
        AdsRequest.queryLaunchAds { (ad, error) -> Void in
            complete?(ad, error)
        }
    }
    
    // 完善信息
    static func completeInfomation(_ name: String, gender: Bool, age: UInt8, height: UInt8, phone: String?, organizationCode: String?, headURL: String?, complete: @escaping ((_ error: NSError?) -> Void)) {
        
        if UserData.sharedInstance.userId == nil {
            complete(NSError(domain: "\(#function)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
        
        UserRequest.completeUserInfo(Int(UserData.sharedInstance.userId!), gender: gender, height: height, age: age, name: name, phone: phone, organizationCode: organizationCode, imageURL: headURL) { (imageURLStr, error) -> Void in
            
            if headURL != nil {
                _ = try? FileManager.default.removeItem(atPath: headURL!)
            }
            
            if error == nil {
                UserData.sharedInstance.name = name
                UserData.sharedInstance.gender = gender
                UserData.sharedInstance.age = age
                UserData.sharedInstance.height = height
                
                UserData.sharedInstance.phone = phone
                UserData.sharedInstance.organizationCode = organizationCode
                
                UserData.sharedInstance.headURL = imageURLStr
            }
            
            complete(error)
        }
    }
    
    static func uploadHeadIcon(_ imageURL: URL, complete: ((_ error: NSError?) -> Void)) {
        if UserData.sharedInstance.userId == nil {
            complete(NSError(domain: "\(#function)", code: 0, userInfo: [NSLocalizedDescriptionKey: "未登录请先登录"]))
            return
        }
    }
    
    // 登出
    static func logout() {
        
        bindQQOpenId = nil
        bindWeiBoOpenId = nil
        bindWeChatOpenId = nil
        UserData.sharedInstance.clearDatas()
        
        
    }
    
    
    // 初始化ShareSDK
    static func initShareSDK() {
        ShareSDKHelper.initSDK()
    }
    
    static func isExistShareApp(_ shareType: ShareType) -> Bool {
        return ShareSDKHelper.isExistShareType(shareType)
    }
    
    // MARK: - 第三方方法
    // 通过QQ登录
    static func loginWithQQ(_ complete: @escaping ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithQQ { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.QQ, unionid: nil, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    // 通过WeChat登录
    static func loginWithWeChat(_ complete: @escaping ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithWeChat { (uid, name, headIcon, unionid, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.WeChat, unionid: unionid, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    // 通过WeiBo登录
    static func loginWithWeiBo(_ complete: @escaping ((NSError?) -> Void)) {
        ShareSDKHelper.loginWithWeiBo { (uid, name, headIcon, error) -> Void in
            // deal userInfo
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: ThirdPlatformType.Weibo, unionid: nil, complete: complete)
            }
            else {
                complete(error)
            }
        }
    }
    
    static func loginThirdPlatform(_ type: ThirdPlatformType, complete: @escaping (_ name: String?, _ headURLStr: String?, _ error: NSError?) -> Void) {
        
        func dealLoginFinished(_ uid: String?, name: String?, headIcon: String?, unionid: String?, error: NSError?) {
            if error == nil {
                loginThirdParty(name!, headURLStr: headIcon!, openId: uid!, type: type, unionid: unionid) { (error: NSError?) -> Void in
                    complete(name, headIcon, error)
                }
            }
            else {
                complete(nil, nil, error)
            }
        }
        
        switch type {
        case .QQ:
            ShareSDKHelper.loginWithQQ({ (uid, name, headIcon, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, unionid: nil, error: error)
            })
        case .WeChat:
            ShareSDKHelper.loginWithWeChat({ (uid, name, headIcon, unionid, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, unionid: unionid, error: error)
            })
        case .Weibo:
            ShareSDKHelper.loginWithWeiBo({ (uid, name, headIcon, error) -> Void in
                dealLoginFinished(uid, name: name, headIcon: headIcon, unionid: nil, error: error)
            })
        }
    }
    
    static func loginThirdParty(_ name: String, headURLStr: String, openId: String, type: ThirdPlatformType, unionid: String?, complete: @escaping ((NSError?) -> Void) ) {
        LoginRequest.loginThirdPlatform(name, headURLStr: headURLStr, openId: openId, type: type,unionid: unionid) { (userInfo, error: NSError?) -> Void in
            
            if error == nil {
                parseUserInfo(userInfo!)
            }
            else {
                
                var shareType: ShareType?
                if type == .WeChat {
                    shareType = ShareType.weChatSession
                }
                else if type == .Weibo {
                    shareType = ShareType.weiBo
                }
                else if type == .QQ {
                    shareType = ShareType.qqFriend
                }
                ShareSDKHelper.cancelBind(shareType!)
            }
            complete(error)
            
        }
    }
    
    // MARK: - bind
    static fileprivate var bindQQOpenId: String? {
        get {
            return UserDefaults.standard.value(forKey: "isBindQQ") as? String
        }
        set {
            if newValue != nil {
                UserDefaults.standard.setValue(newValue, forKey: "isBindQQ")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "isBindQQ")
            }
        }
    }
    
    static fileprivate var bindWeChatOpenId: String? {
        get {
            return UserDefaults.standard.value(forKey: "isBindWeChat") as? String
        }
        set {
            if newValue != nil {
                UserDefaults.standard.setValue(newValue, forKey: "isBindWeChat")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "isBindWeChat")
            }
        }
    }
    
    static fileprivate var bindWeiBoOpenId: String? {
        get {
            return UserDefaults.standard.value(forKey: "isBindWeiBo") as? String
        }
        set {
            if newValue != nil {
                UserDefaults.standard.setValue(newValue, forKey: "isBindWeiBo")
            }
            else {
                UserDefaults.standard.removeObject(forKey: "isBindWeiBo")
            }
        }
    }
    
    static func bindThirdParty(_ type: ThirdPlatformType, complete: @escaping (NSError?) -> Void) {
        
        func serverBind(_ openId: String?, type: ThirdPlatformType) {
            LoginRequest.bindThirdPlatform(UserData.sharedInstance.userId!, openId: openId!, type: type) { (error: NSError?) -> Void in
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
            ShareSDKHelper.loginWithWeChat({ (uid, name, headIcon, unionid, error) -> Void in
                if error == nil {
                    serverBind(uid, type: type)
                }
                else {
                    complete(error)
                }
            })
        }
    }
    
    static func cancelBindThirdParty(_ type: ThirdPlatformType, complete: @escaping (NSError?) -> Void) {
        
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
        
        LoginRequest.cancelBindThirdPlatform(UserData.sharedInstance.userId!, openId: openId, type: type) { (error: NSError?) -> Void in
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
    
    static func isBindThirdParty(_ type: ThirdPlatformType) -> Bool {
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
    
    static func parseUserInfo(_ userInfo: [String: AnyObject]) {
        
        if let userId = userInfo["userid"] as? String {
            print("userId\(userId)")
            UserData.sharedInstance.userId = NSString(string: userId).integerValue
            
        }
        
        if let userId = userInfo["userid"] as? NSNumber {
            print("userId\(userId)")
            UserData.sharedInstance.userId = userId.intValue
            
        }
        
        if let userId = userInfo["userId"] as? NSNumber {
            print("userId\(userId)")
            UserData.sharedInstance.userId = userId.intValue
        }
        
        if let phone = userInfo["mobile"] as? NSNumber {
            print("mobile\(phone)")
            if phone != 0 {
                UserData.sharedInstance.phone = phone.stringValue
            }
        }
        
        if let age = userInfo["age"] as? NSNumber {
            print("age\(age)")
            UserData.sharedInstance.age = age.uint8Value
        }
        
        if let gender = userInfo["gender"] as? NSNumber {
            print("gender\(gender)")
            UserData.sharedInstance.gender = gender.intValue == 1 ? true : false
        }
        
        if let head = userInfo["headURL"] as? String {
            print("head\(head)")
            UserData.sharedInstance.headURL = head
        }
        
        if let height = userInfo["height"] as? NSNumber {
            print("height\(height)")
            UserData.sharedInstance.height = height.uint8Value
        }
        
        if let name = userInfo["name"] as? String {
            print("name\(name)")
            UserData.sharedInstance.name = name
        }
        
        if let organizationCode = userInfo["organizationCode"] as? String {
            print("organizationCode\(organizationCode)")
            if organizationCode != "" {
                UserData.sharedInstance.organizationCode = organizationCode
            }
        }
        
        if let childs = userInfo["child"] as? [[String : AnyObject]] {
            DBManager.sharedInstance.deleteAllUser()
            for info in childs {
                let userModel = UserModel(info: info)
                DBManager.sharedInstance.addOrUpdateUser(userModel)
            }
        }
        
        // 如果不需要完善信息
        if !LoginManager.isNeedCompleteInfo {
            UserManager.sharedInstance.currentUser = UserManager.mainUser
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
