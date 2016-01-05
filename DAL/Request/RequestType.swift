//
//  RequestType.swift
//  Health
//
//  Created by Yalin on 15/9/8.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

enum RequestType: String {
    case Login = "100002"
    case QueryCaptchas = "100010"
    case LoginThirdPlatform = "100003"
    case BindThirdPlatform = "100004"
    case CancelBindThirdPlatform = "100030" // 解除绑定接口  传 userId 和  openId 的值就行
    
    case CreateUser = "100009"
    case DeleteUser = "100016"
    case CompleteUserInfo = "100005"
    
    case QueryEvaluationDatas = "100023"
    case UploadEvaluationDatas = "100013"
    case DeleteEvaluationData = "100014"
    case DeleteEvaluationDatas = "100015"
    
    case QueryGoalDatas = "100020"
    case UploadGoalDatas = "100019"
    case DeleteGoalData = "100021"
    case DeleteGoalDatas = "100024"
    
    case UploadSettingGoalDatas = "100031"
    case QuerySettingGoalDatas = "100032"
    
    case QueryScore = "100017"
    case Share = "100018"
    case QueryBadge = "100029"  // 获取徽章 传userId
    
    case QueryLaunchAds = "100011"
    case QueryActivityAds = "100012"
    
    case FeedBack = "100007"
    
    
    func startRequest(params: [String : AnyObject], completionHandler: (data: NSData! , response: NSURLResponse!, error: NSError!) -> Void) {
        Request.startWithRequest(self, params: params, completionHandler: completionHandler)
    }
}


enum ThirdPlatformType: String {
    case WeChat = "1"
    case Weibo = "2"
    case QQ = "3"
}

