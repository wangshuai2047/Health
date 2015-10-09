//
//  ShareSDKHelper.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

enum ShareType {
    case QQ
    case WeiBo
    case WeiChat
}

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
    static let sinaWeiboAppRedirectURI = "https://api.weibo.com/oauth2/default.html"
    
    static let weChatAppId = "wxac0b90fe1dda50a2"
    static let weChatAppSecret = "c510ad4ded20907e5b11fa278b8da505"
    
    static let QQAppId = "1104780739"
    static let QQAppkey = "rB5SFbkLlVuevi54"
    
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
                    appInfo.SSDKSetupSinaWeiboByAppKey(self.sinaWeiboAppKey, appSecret: self.sinaWeiboAppSecret, redirectUri: sinaWeiboAppRedirectURI, authType: SSDKAuthTypeSSO)
                case .TypeWechat:
                    appInfo.SSDKSetupWeChatByAppId(self.weChatAppId, appSecret: self.weChatAppSecret)
                case .TypeQQ:
                    appInfo.SSDKSetupQQByAppId(self.QQAppId, appKey: self.QQAppkey, authType: SSDKAuthTypeBoth)
                default:
                    break
                }
        }
    }
    
    // MARK: - 登录
    static func loginWithWeiBo(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeSinaWeibo, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            var err: NSError? = nil
            if response == SSDKResponseState.Cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(uid: nil, name: nil, headIcon: nil, error: err)
            }
            else if response == SSDKResponseState.Fail {
                complete(uid: nil, name: nil, headIcon: nil, error: error)
            }
            else if response == SSDKResponseState.Success {
                complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: nil)
            }
        })
    }
    
    static func loginWithWeChat(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeWechat, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            var err: NSError? = nil
            if response == SSDKResponseState.Cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(uid: nil, name: nil, headIcon: nil, error: err)
            }
            else if response == SSDKResponseState.Fail {
                complete(uid: nil, name: nil, headIcon: nil, error: error)
            }
            else if response == SSDKResponseState.Success {
                complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: nil)
            }
            
        })
    }
    
    static func loginWithQQ(complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeQQ, onStateChanged: { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            var err: NSError? = nil
            if response == SSDKResponseState.Cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(uid: nil, name: nil, headIcon: nil, error: err)
            }
            else if response == SSDKResponseState.Fail {
                complete(uid: nil, name: nil, headIcon: nil, error: error)
            }
            else if response == SSDKResponseState.Success {
                complete(uid: user.uid, name: user.nickname == nil ? "" : user.nickname, headIcon: user.icon == nil ? "" : user.icon, error: nil)
            }
        })
    }
    
    static func isExistShareType(type: ShareType) -> Bool {
        if type == .QQ {
            return ShareSDK.isSupportAuth(.TypeQQ)
        }
        else if type == .WeiBo {
            return ShareSDK.isSupportAuth(.TypeSinaWeibo)
        }
        else if type == .WeiChat {
            return ShareSDK.isSupportAuth(.TypeWechat)
        }
        
        return false
    }
    
    // MARK: - 分享
    static func shareEvaluationImage(shareType: ShareType, image: UIImage) {
//        ShareSDK.
        let shareInfo: NSMutableDictionary = NSMutableDictionary()
        
        if shareType == ShareType.WeiChat {
//            shareInfo.SSDKSetupWeChatParamsByText("test text", title: "test title", url: NSURL(string: "http://www.baidu.com"), thumbImage: UIImage(named: "appIcon"), image: image, musicFileURL: <#T##NSURL!#>, extInfo: <#T##String!#>, fileData: <#T##AnyObject!#>, emoticonData: <#T##AnyObject!#>, type: <#T##SSDKContentType#>, forPlatformSubType: <#T##SSDKPlatformType#>)
        }
        
//        ShareSDK.share(<#T##platformType: SSDKPlatformType##SSDKPlatformType#>, parameters: <#T##NSMutableDictionary!#>, onStateChanged: <#T##SSDKShareStateChangedHandler!##SSDKShareStateChangedHandler!##(SSDKResponseState, [NSObject : AnyObject]!, SSDKContentEntity!, NSError!) -> Void#>)
    }
}
