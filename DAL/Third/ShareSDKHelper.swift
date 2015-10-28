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
    
    func toThirdPlatformType() -> ThirdPlatformType {
        switch self {
        case .WeChatSession, .WeChatTimeline:
            return ThirdPlatformType.WeChat
        case .QQFriend:
            return ThirdPlatformType.QQ
        case .WeiBo:
            return ThirdPlatformType.Weibo
        }
    }
    
    init(type: ThirdPlatformType) {
        if type == .Weibo {
            self = .WeiBo
        }
        else if type == .WeChat {
            self = .WeChatSession
        }
        else if type == .QQ {
            self = .QQFriend
        }
        else {
            self = .WeiBo
        }
    }
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
    
    static var qqInfo: [String : AnyObject]? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("QQHealthInfo") as? [String : AnyObject]
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "QQHealthInfo")
        }
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
                qqInfo = ["qqUserOpenId" : user.uid, "qqToken" : user.credential.token]
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
    
    // 记步数据同步 distance单位米 duration单位秒 calories单位千卡
    static func syncStepsDatas(date: NSDate, distance: Int, steps: Int, duration: Int, calories: Int, complete: (NSError?) -> Void) {
        syncQQHealthData("report_steps", params: [
            "time" : date.timeIntervalSince1970,
            "distance" : distance,
            "steps" : steps,
            "duration" : duration,
            "calories" : calories
            ], complete: complete)
    }
    
    // 体重体质数据同步
    static func syncBodyDatas(date: NSDate, weight: Float, fat_per: Float, bmi: Float, complete: (NSError?) -> Void) {
        syncQQHealthData("report_weight", params: [
            "time" : date.timeIntervalSince1970,
            "weight" : weight,
            "fat_per" : fat_per,
            "bmi" : bmi
            ], complete: complete)
    }
    
    // 睡眠数据同步
/*
    end_time        Int     -        睡眠结束的时间戳(从 1970-01-01 00:00:00 秒数)
    ￼start_time      Int     -        睡眠开始的时间戳(从 1970-01-01 00:00:00 秒数)
    total_time      Int     分钟      今日睡眠总时间
    light_sleep     Int     分钟      今日浅睡眠总时间
    deep_sleep      Int     分钟      今日深睡眠总时间
    awake_time      Int     分钟      今日睡眠期间醒来状态的总时间
    detail          String  -        睡眠阶段详情数据,格式[起始时间点,睡眠状态] (1-睡醒,2-浅睡眠,3-深睡眠), 当深睡, 浅睡,清醒,有状态改变时记录,例如 [1405585306,2],[1405591306,3],[1405631306,2]
*/
    static func syncSleepDatas(start_time: NSDate, end_time: NSDate, total_time: Int, light_sleep: Int, deep_sleep: Int, awake_time: Int, detail: String, complete: (NSError?) -> Void) {
        syncQQHealthData("report_sleep", params: [
            "start_time" : start_time.timeIntervalSince1970,
            "end_time" : end_time.timeIntervalSince1970,
            "total_time" : total_time,
            "light_sleep" : light_sleep,
            "deep_sleep" : deep_sleep,
            "awake_time" : awake_time,
            "detail" : detail
            ], complete: complete)
    }
    
    // 健康中心请求数据
    private static func syncQQHealthData(interfaceName: String, params: [String : AnyObject], complete: (NSError?) -> Void) {
        var urlStr = "https://openmobile.qq.com/v3/health/\(interfaceName)?"
        
        // 配置参数
        var paramsArr: [String] = []
        for key in params.keys {
            paramsArr.append("\(key)=\(params[key])")
        }
        
        
        // 内置参数
        // access_token
        if let access_token = qqInfo?["qqToken"] as? String {
            paramsArr.append("access_token=\(access_token)")
        }
        else {
            // 错误
            complete(NSError(domain: "ShareSDKHelper Error", code: -1, userInfo: [NSLocalizedDescriptionKey : "access_token 参数没有 未登录"]))
            return
        }
        
        // oauth_consumer_key
        paramsArr.append("oauth_consumer_key=\(QQAppId)")
        
        // openid
        if let openid = qqInfo?["qqUserOpenId"] as? String {
            paramsArr.append("openid=\(openid)")
        }
        else {
            // 错误
            complete(NSError(domain: "ShareSDKHelper Error", code: -1, userInfo: [NSLocalizedDescriptionKey : "openid 参数没有 未登录"]))
            return
        }
        
        // pf=qzone
        paramsArr.append("pf=qzone")
        
        // 合成URL
        urlStr += paramsArr.joinWithSeparator("&")
        
        // URL编码
        
        // 发送请求
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
        request.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            
            var err = error
            if error != nil {
                do {
                    let result : NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!,  options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                    print("syncQQHealthData  \(result)")
                    if let jsonObj = result {
                        
                        if let code = jsonObj.valueForKey("ret") as? Int {
                            if code >= 0 {
                                // 请求成功
                                err = nil
                            }
                            else {
                                // 请求失败
                                if let msg = jsonObj.valueForKey("msg") as? String {
                                    err = NSError(domain: "QQHealth error", code: code, userInfo: [NSLocalizedDescriptionKey : msg])
                                }
                                else
                                {
                                    err = NSError(domain: "QQHealth Server logic error", code: code, userInfo: [NSLocalizedDescriptionKey : "QQHealth Server not return the detail error message"])
                                }
                            }
                        }
                    }
                } catch let error1 as NSError {
                    err = error1
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                complete(err)
            })
        })
        
        task.resume()
        
    }
}
