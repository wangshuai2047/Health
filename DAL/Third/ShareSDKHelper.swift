//
//  ShareSDKHelper.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

enum ShareType: Int {
    case WeChatSession = 1  // 微信好友
    case WeiBo  // 新浪微博
    case QQFriend   // qq 好友
    case WeChatTimeline // 微信朋友圈
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
    
    private static func shareTypeToSSDKPlatformType(type: ShareType) -> SSDKPlatformType {
        if type == ShareType.QQFriend {
            return SSDKPlatformType.TypeQQ
        }
        else if type == ShareType.WeiBo {
            return .TypeSinaWeibo
        }
        else if type == ShareType.WeChatSession || type == ShareType.WeChatTimeline {
            return SSDKPlatformType.TypeWechat
        }
        
        return SSDKPlatformType.TypeQQ
    }
    
    // MARK: - 绑定
    static func isBind(shareType: ShareType) -> Bool {
        return ShareSDK.hasAuthorized(shareTypeToSSDKPlatformType(shareType))
    }
    
    static func bind(shareType: ShareType, complete: ((uid: String?, name: String?, headIcon: String?, error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(shareTypeToSSDKPlatformType(shareType)) { (response: SSDKResponseState, user: SSDKUser!, error: NSError!) -> Void in
            var err: NSError? = nil
            if response == SSDKResponseState.Cancel {
                err = NSError(domain: "绑定失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消绑定"])
                complete(uid: nil, name: nil, headIcon: nil, error: err)
            }
            else if response == SSDKResponseState.Fail {
                complete(uid: nil, name: nil, headIcon: nil, error: error)
            }
            else if response == SSDKResponseState.Success {
                complete(uid: user.uid, name: user.nickname, headIcon: user.icon, error: nil)
            }
        }
    }
    
    static func cancelBind(type: ShareType) {
        ShareSDK.cancelAuthorize(shareTypeToSSDKPlatformType(type))
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
        
        return ShareSDK.isSupportAuth(shareTypeToSSDKPlatformType(type))
    }
    
    // MARK: - 分享
    static func shareImage(shareType: ShareType, image: UIImage, isEvaluation: Bool, complete: (NSError?) -> Void) {
//        ShareSDK.
        var shareInfo: NSMutableDictionary?
        var platformType: SSDKPlatformType?
        
        if shareType == ShareType.WeChatSession {
            shareInfo = weChatShareData(image, isEvaluation: isEvaluation, forPlatformSubType: SSDKPlatformType.SubTypeWechatSession)
            platformType = SSDKPlatformType.SubTypeWechatSession
        }
        else if shareType == ShareType.WeChatTimeline {
            shareInfo = weChatShareData(image, isEvaluation: isEvaluation, forPlatformSubType: SSDKPlatformType.SubTypeWechatTimeline)
            platformType = SSDKPlatformType.SubTypeWechatTimeline
        }
        else if shareType == ShareType.QQFriend {
            shareInfo = QQShareData(image, isEvaluation: isEvaluation)
            platformType = SSDKPlatformType.SubTypeQQFriend
        }
        else {
            shareInfo = sinaShareData(image, isEvaluation: isEvaluation)
            platformType = SSDKPlatformType.TypeSinaWeibo
        }
        
        ShareSDK.share(platformType!, parameters: shareInfo!) { (status: SSDKResponseState, info: [NSObject : AnyObject]!, entity: SSDKContentEntity!, error: NSError!) -> Void in
            
            var err: NSError? = nil
            if status == SSDKResponseState.Cancel {
                err = NSError(domain: "分享失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消分享"])
                complete(err)
            }
            else if status == SSDKResponseState.Fail {
                complete(error)
            }
            else if status == SSDKResponseState.Success {
                complete(nil)
            }
        }
    }
    
    private static func sinaShareData(image: UIImage, isEvaluation: Bool) -> NSMutableDictionary {
        let shareInfo = NSMutableDictionary()
        
        shareInfo.SSDKSetupSinaWeiboShareParamsByText("text 好体知SinaWeiBo分享测试", title: "title 好体知SinaWeiBo分享测试", image: image, url: nil, latitude: 0, longitude: 0, objectID: nil, type: SSDKContentType.Image)
        
        return shareInfo
    }
    
    private static func weChatShareData(image: UIImage, isEvaluation: Bool, forPlatformSubType: SSDKPlatformType) -> NSMutableDictionary {
        let shareInfo = NSMutableDictionary()
        
        shareInfo.SSDKSetupWeChatParamsByText(nil, title: "title 好体知微信分享测试", url: nil, thumbImage: UIImage(named: "appIcon"), image: image, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, type: SSDKContentType.Image, forPlatformSubType: forPlatformSubType)
        
        return shareInfo
    }
    
    private static func QQShareData(image: UIImage, isEvaluation: Bool) -> NSMutableDictionary {
        let shareInfo = NSMutableDictionary()
        
        shareInfo.SSDKSetupQQParamsByText("text 好体知QQ分享测试", title: "title 好体知QQ分享测试", url: nil, thumbImage: UIImage(named: "appIcon"), image: image, type: SSDKContentType.Image, forPlatformSubType: SSDKPlatformType.TypeQQ)
        
        return shareInfo
    }
}
