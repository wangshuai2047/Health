//
//  ShareSDKHelper.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct ShareSDKHelper {
   
    static let shareSDKAppKey = "9bb6bfaeadf0"
    static let shareSDKAppSecret = "c99e9509dda33cb69bc70c70f3a8ebc7"
    
    static let sinaWeiboAppKey = "3871619455"
    static let sinaWeiboAppSecret = "Secret：b3cf51bc1a85e55787357e7c157c21d3"
    
    static let weChatAppId = ""
    static let weChatAppSecret = ""
    
    static let QQAppId = ""
    static let QQAppkey = ""
    
    static func initSDK() {
        ShareSDK.registerApp(shareSDKAppKey, activePlatforms: [SSDKPlatformType.TypeSinaWeibo.rawValue, SSDKPlatformType.TypeWechat.rawValue, SSDKPlatformType.TypeQQ.rawValue], onImport: { (platform: SSDKPlatformType) -> Void in
            
            switch platform {
            case .TypeSinaWeibo:
                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
            case .TypeWechat:
                ShareSDKConnector.connectWeChat(WXApi.classForCoder())
            case .TypeQQ:
                ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
            default:
                break
            }
            
            }) { (platform: SSDKPlatformType, appInfo: NSMutableDictionary!) -> Void in
                
                switch platform {
                case .TypeSinaWeibo:
                    // 设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                    appInfo.SSDKSetupSinaWeiboByAppKey(self.sinaWeiboAppKey, appSecret: self.sinaWeiboAppSecret, redirectUri: "http://www.sharesdk.cn", authType: SSDKAuthTypeBoth)
                case .TypeWechat:
                    appInfo.SSDKSetupWeChatByAppId(self.weChatAppId, appSecret: self.weChatAppSecret)
                case .TypeQQ:
                    appInfo.SSDKSetupQQByAppId(self.QQAppId, appKey: self.QQAppkey, authType: SSDKAuthTypeBoth)
                default:
                    break
                }
        }
    }
    
    static func loginWithWeiBo(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeSinaWeibo, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: error)
        })
    }
    
    static func loginWithWeChat(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeWechat, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: error)
        })
    }
    
    static func loginWithQQ(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeQQ, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: error)
        })
    }
}
