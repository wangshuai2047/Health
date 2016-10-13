//
//  ShareSDKHelper.swift
//  Health
//
//  Created by Yalin on 15/8/19.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
//import ShareSDK

enum ShareType: Int {
    case weChatSession = 1  // 微信好友
    case weiBo  // 新浪微博
    case qqFriend   // qq 好友
    case weChatTimeline // 微信朋友圈
    
    func toThirdPlatformType() -> ThirdPlatformType {
        switch self {
        case .weChatSession, .weChatTimeline:
            return ThirdPlatformType.WeChat
        case .qqFriend:
            return ThirdPlatformType.QQ
        case .weiBo:
            return ThirdPlatformType.Weibo
        }
    }
    
    init(type: ThirdPlatformType) {
        if type == .Weibo {
            self = .weiBo
        }
        else if type == .WeChat {
            self = .weChatSession
        }
        else if type == .QQ {
            self = .qqFriend
        }
        else {
            self = .weiBo
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
    
    static let sinaWeiboAppKey = "3329439896"
    static let sinaWeiboAppSecret = "fc4d61248d9fb33c35a9e5afb4cc2b5c"
    static let sinaWeiboAppRedirectURI = "https://api.weibo.com/oauth2/default.html"
    
    static let weChatAppId = "wxac0b90fe1dda50a2"
    static let weChatAppSecret = "c510ad4ded20907e5b11fa278b8da505"
    
    static let QQAppId = "1104780739"
    static let QQAppkey = "rB5SFbkLlVuevi54"
    
    static func initSDK() {
        ShareSDK.registerApp(shareSDKAppKey, activePlatforms: [SSDKPlatformType.typeSinaWeibo.rawValue, SSDKPlatformType.typeWechat.rawValue, SSDKPlatformType.typeQQ.rawValue], onImport: { (platform: SSDKPlatformType) -> Void in
            
            switch platform {
            case .typeSinaWeibo:
                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
            case .typeWechat:
                ShareSDKConnector.connectWeChat(WXApi.classForCoder())
            case .typeQQ:
                ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
            default:
                break
            }
            
            }) { (platform: SSDKPlatformType, appInfo: NSMutableDictionary?) in
                
                switch platform {
                case .typeSinaWeibo:
                    // 设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                    appInfo?.ssdkSetupSinaWeibo(byAppKey: self.sinaWeiboAppKey, appSecret: self.sinaWeiboAppSecret, redirectUri: sinaWeiboAppRedirectURI, authType: SSDKAuthTypeSSO)
                case .typeWechat:
                    appInfo?.ssdkSetupWeChat(byAppId: self.weChatAppId, appSecret: self.weChatAppSecret)
                case .typeQQ:
                    appInfo?.ssdkSetupQQ(byAppId: self.QQAppId, appKey: self.QQAppkey, authType: SSDKAuthTypeBoth)
                default:
                    break
                }
        }
    }
    
    fileprivate static func shareTypeToSSDKPlatformType(_ type: ShareType) -> SSDKPlatformType {
        if type == ShareType.qqFriend {
            return SSDKPlatformType.typeQQ
        }
        else if type == ShareType.weiBo {
            return .typeSinaWeibo
        }
        else if type == ShareType.weChatSession || type == ShareType.weChatTimeline {
            return SSDKPlatformType.typeWechat
        }
        
        return SSDKPlatformType.typeQQ
    }
    
    // MARK: - 绑定
    static func isBind(_ shareType: ShareType) -> Bool {
        return ShareSDK.hasAuthorized(shareTypeToSSDKPlatformType(shareType))
    }
    
    static func bind(_ shareType: ShareType, complete: @escaping ((_ uid: String?, _ name: String?, _ headIcon: String?, _ error: NSError?) -> Void)) {
        
        ShareSDK.getUserInfo(shareTypeToSSDKPlatformType(shareType)) { (response: SSDKResponseState, user: SSDKUser?, error: Error?) in
            
            var err: NSError? = nil
            if response == SSDKResponseState.cancel {
                err = NSError(domain: "绑定失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消绑定"])
                complete(nil, nil, nil, err)
            }
            else if response == SSDKResponseState.fail {
                complete(nil, nil, nil, error as NSError?)
            }
            else if response == SSDKResponseState.success {
                complete(user?.uid, user?.nickname, user?.icon, nil)
            }
        }
    }
    
    static func cancelBind(_ type: ShareType) {
        ShareSDK.cancelAuthorize(shareTypeToSSDKPlatformType(type))
    }
    
    // MARK: - 登录
    static func loginWithWeiBo(_ complete: @escaping ((_ uid: String?, _ name: String?, _ headIcon: String?, _ error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeSinaWeibo, onStateChanged: { (response: SSDKResponseState, user: SSDKUser?, error: Error?) in
//            NSLog("loginWithWeiBo: %@ ssl: %@ --- %@", user.rawData,user.credential.rawData, user.credential.token)
            var err: NSError? = nil
            
            if response == SSDKResponseState.cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(nil, nil, nil, err)
            }
            else if response == SSDKResponseState.fail {
                complete(nil, nil, nil, error as NSError?)
            }
            else if response == SSDKResponseState.success {
                complete(user?.uid, user?.nickname, user?.icon, nil)
            }
        })
    }
    
    static func loginWithWeChat(_ complete: @escaping ((_ uid: String?, _ name: String?, _ headIcon: String?, _ unionid: String?, _ error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeWechat, onStateChanged: { (response: SSDKResponseState, user: SSDKUser?, error: Error?) in
            var err: NSError? = nil
//            NSLog("loginWithWeChat: %@ ssl: %@ --- %@", user.rawData,user.credential.rawData, user.credential.token)
            if response == SSDKResponseState.cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(nil, nil, nil, nil, err)
            }
            else if response == SSDKResponseState.fail {
                complete(nil, nil, nil, nil, error as NSError?)
            }
            else if response == SSDKResponseState.success {
                complete(user?.uid, user?.nickname, user?.icon, user?.rawData["unionid"] as? String, nil)
            }
            
        })
    }
    
    static var qqInfo: [String : AnyObject]? {
        get {
            return UserDefaults.standard.object(forKey: "QQHealthInfo") as? [String : AnyObject]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "QQHealthInfo")
        }
    }
    
    static func loginWithQQ(_ complete: @escaping ((_ uid: String?, _ name: String?, _ headIcon: String?, _ error: NSError?) -> Void)) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeQQ, onStateChanged: { (response: SSDKResponseState, user: SSDKUser?, error: Error?) in
//            NSLog("loginWithQQ: ssl: %@ --- %@", user.rawData,user.credential.rawData, user.credential.token)
            
            var err: NSError? = nil
            if response == SSDKResponseState.cancel {
                err = NSError(domain: "登录失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消登录"])
                complete(nil, nil, nil, err)
            }
            else if response == SSDKResponseState.fail {
                complete(nil, nil, nil, error as NSError?)
            }
            else if response == SSDKResponseState.success {
                qqInfo = ["qqUserOpenId" : user?.uid as AnyObject, "qqToken" : user?.credential.token as AnyObject]
                complete(user?.uid, user?.nickname == nil ? "" : user?.nickname, user?.icon == nil ? "" : user?.icon, nil)
            }
        })
    }
    
    static func isExistShareType(_ type: ShareType) -> Bool {
        if type == .weChatSession || type == .weChatTimeline {
            return WXApi.isWXAppInstalled()
        }
        else if type == .weiBo {
            return WeiboSDK.isWeiboAppInstalled()
            
        }
        else {
            return QQApi.isQQInstalled()
        }
    }
    
    // MARK: - 分享
    static func shareImage(_ shareType: ShareType, image: UIImage, isEvaluation: Bool, complete: @escaping (NSError?) -> Void) {
//        ShareSDK.
        var shareInfo: NSMutableDictionary?
        var platformType: SSDKPlatformType?
        
        if shareType == ShareType.weChatSession {
            shareInfo = weChatShareData(image, isEvaluation: isEvaluation, forPlatformSubType: SSDKPlatformType.subTypeWechatSession)
            platformType = SSDKPlatformType.subTypeWechatSession
        }
        else if shareType == ShareType.weChatTimeline {
            shareInfo = weChatShareData(image, isEvaluation: isEvaluation, forPlatformSubType: SSDKPlatformType.subTypeWechatTimeline)
            platformType = SSDKPlatformType.subTypeWechatTimeline
        }
        else if shareType == ShareType.qqFriend {
            //构造分享内容
            shareInfo = QQShareData(image, isEvaluation: isEvaluation)
            platformType = SSDKPlatformType.subTypeQQFriend
        }
        else {
            shareInfo = sinaShareData(image, isEvaluation: isEvaluation)
            platformType = SSDKPlatformType.typeSinaWeibo
        }
        
        ShareSDK.share(platformType!, parameters: shareInfo!) { (status: SSDKResponseState, info: [AnyHashable: Any]?, entity: SSDKContentEntity?, error: Error?) in
            
            var err: NSError? = nil
            if status == SSDKResponseState.cancel {
                err = NSError(domain: "分享失败", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户取消分享"])
                complete(err)
            }
            else if status == SSDKResponseState.fail {
                complete(error as NSError?)
            }
            else if status == SSDKResponseState.success {
                complete(nil)
            }
        }
    }
    
    fileprivate static func sinaShareData(_ image: UIImage, isEvaluation: Bool) -> NSMutableDictionary {
        let shareInfo = NSMutableDictionary()
        
        shareInfo.ssdkSetupSinaWeiboShareParams(byText: "text 好体知SinaWeiBo分享测试", title: "title 好体知SinaWeiBo分享测试", image: image, url: nil, latitude: 0, longitude: 0, objectID: nil, type: SSDKContentType.image)
        
        return shareInfo
    }
    
    fileprivate static func weChatShareData(_ image: UIImage, isEvaluation: Bool, forPlatformSubType: SSDKPlatformType) -> NSMutableDictionary {
        
        
        let shareInfo = NSMutableDictionary()
        
        shareInfo.ssdkSetupWeChatParams(byText: nil, title: "title 好体知微信分享测试", url: nil, thumbImage: UIImage(named: "appIcon"), image: image, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, type: SSDKContentType.image, forPlatformSubType: forPlatformSubType)
        
        return shareInfo
    }
    
    /**
     *  设置QQ分享参数
     *
     *  @param text            分享内容
     *  @param title           分享标题
     *  @param url             分享链接
     *  @param thumbImage      缩略图，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
     *  @param image           图片，可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage
     *  @param type            分享类型, 仅支持Text（仅QQFriend）、Image（仅QQFriend）、WebPage、Audio、Video类型
     *  @param platformSubType 平台子类型，只能传入SSDKPlatformSubTypeQZone或者SSDKPlatformSubTypeQQFriend其中一个
     */
    fileprivate static func QQShareData(_ image: UIImage, isEvaluation: Bool) -> NSMutableDictionary {
        let shareInfo = NSMutableDictionary()
        
        shareInfo.ssdkSetupQQParams(byText: nil, title: "title 好体知QQ分享测试", url: nil, thumbImage: UIImage(named: "appIcon"), image: image, type: SSDKContentType.image, forPlatformSubType: SSDKPlatformType.typeQQ)
        shareInfo.setValue("好体知分享", forKey: "text")
        shareInfo.setValue("好体知分享", forKey: "title")
        shareInfo.setValue(SSDKImage(image: UIImage(named: "appIcon"), format: SSDKImageFormatJpeg, settings: [:]), forKey: "thumbImage")
        shareInfo.setValue([SSDKImage(image: image, format: SSDKImageFormatJpeg, settings: [:])], forKey: "images")
        shareInfo.setValue(NSNumber(value: SSDKContentType.image.rawValue as UInt), forKey: "type")
        shareInfo.setValue(NSNumber(value: SSDKPlatformType.typeQQ.rawValue as UInt), forKey: "platformSubType")
        
        return shareInfo
    }
    
    // 记步数据同步 distance单位米 duration单位秒 calories单位千卡
    static func syncStepsDatas(_ date: Date, distance: Int, steps: Int, duration: Int, calories: Int, complete: @escaping (NSError?) -> Void) {
        syncQQHealthData("report_steps", params: [
            "time" : date.timeIntervalSince1970 as AnyObject,
            "distance" : distance as AnyObject,
            "steps" : steps as AnyObject,
            "duration" : duration as AnyObject,
            "calories" : calories as AnyObject
            ], complete: complete)
    }
    
    // 体重体质数据同步
    static func syncBodyDatas(_ date: Date, weight: Float, fat_per: Float, bmi: Float, complete: @escaping (NSError?) -> Void) {
        syncQQHealthData("report_weight", params: [
            "time" : date.timeIntervalSince1970 as AnyObject,
            "weight" : weight as AnyObject,
            "fat_per" : fat_per as AnyObject,
            "bmi" : bmi as AnyObject
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
    static func syncSleepDatas(_ start_time: Date, end_time: Date, total_time: Int, light_sleep: Int, deep_sleep: Int, awake_time: Int, detail: String, complete: @escaping (NSError?) -> Void) {
        syncQQHealthData("report_sleep", params: [
            "start_time" : start_time.timeIntervalSince1970 as AnyObject,
            "end_time" : end_time.timeIntervalSince1970 as AnyObject,
            "total_time" : total_time as AnyObject,
            "light_sleep" : light_sleep as AnyObject,
            "deep_sleep" : deep_sleep as AnyObject,
            "awake_time" : awake_time as AnyObject,
            "detail" : detail as AnyObject
            ], complete: complete)
    }
    
    // 健康中心请求数据
    fileprivate static func syncQQHealthData(_ interfaceName: String, params: [String : AnyObject], complete: @escaping (NSError?) -> Void) {
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
        urlStr += paramsArr.joined(separator: "&")
        
        // URL编码
        
        // 发送请求
        var request : URLRequest = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response:URLResponse?, error: Error?) in
            
            var err = error
            if error != nil {
                do {
                    let result : NSDictionary? = try JSONSerialization.jsonObject(with: data!,  options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary
                    print("syncQQHealthData  \(result)")
                    if let jsonObj = result {
                        
                        if let code = jsonObj.value(forKey: "ret") as? Int {
                            if code >= 0 {
                                // 请求成功
                                err = nil
                            }
                            else {
                                // 请求失败
                                if let msg = jsonObj.value(forKey: "msg") as? String {
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
            
            DispatchQueue.main.async(execute: { () -> Void in
                complete(err as NSError?)
            })
        })
        
        task.resume()
        
    }
}
