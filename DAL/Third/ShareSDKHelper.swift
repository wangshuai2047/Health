//
//  ShareSDKHelper.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

/*
1、	http://mob.com/#/index   分享账号为：2844062095@qq.com  密码：cstf158
2、	新浪微博开发者账号为：2844062095@qq.com  密码：cstf158
3、	微信开发者账号：huang_l@thtf.com.cn  密码：cstf158
4、	腾讯开发者账号：2844062095  密码：cstf158
*/
struct ShareSDKHelper {
   
    static let shareSDKAppKey = "a4fd2ee725e8"
    static let shareSDKAppSecret = "96eaf1881e7e37847fcdc75bf4f833c2"
    
    static let sinaWeiboAppKey = "4153895349"
    static let sinaWeiboAppSecret = "1ecfe5957e5d1450c4444fb75a1e1718"
    
    static let weChatAppId = "wxac0b90fe1dda50a2"
    static let weChatAppSecret = "c510ad4ded20907e5b11fa278b8da505"
    
    static let QQAppId = "1104855778"
    static let QQAppkey = "mgysQido1HgLMDXP"
    
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
