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
    
    case CreateUser = "100004"
    case DeleteUser = "1000061"
    case CompleteUserInfo = "100005"
    
    case QueryEvaluationDatas = "1000071"
    case UploadEvaluationDatas = "100013"
    case DeleteEvaluationData = "100014"
    case DeleteEvaluationDatas = "100015"
    
    case QueryGoalDatas = "10001011"
    case UploadGoalDatas = "1000111"
    case DeleteGoalData = "1000112"
    case DeleteGoalDatas = "10001123"
    
    case QueryScore = "1000131"
    case Share = "1000141"
    
    case QueryLaunchAds = "100011"
    case QueryActivityAds = "100012"
    
    case FeedBack = "100007"
    
    
    func startRequest(params: [String : AnyObject], completionHandler: (data: NSData! , response: NSURLResponse!, error: NSError!) -> Void) {
        Request.startWithRequest(self, params: params, completionHandler: completionHandler)
    }
}


enum ThirdPlatformType: String {
    case WeiChat = "1"
    case Weibo = "2"
    case QQ = "3"
}

