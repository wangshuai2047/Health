//
//  SettingManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct SettingManager {
    static var isConnectMyBody: Bool {
        return DBManager.sharedInstance.haveConnectedWithType(DeviceType.myBody)
    }
    static var isConnectMyBodyMini: Bool {
        return DBManager.sharedInstance.haveConnectedWithType(DeviceType.myBodyMini)
    }
    static var isConnectMyBodyPlus: Bool {
        return DBManager.sharedInstance.haveConnectedWithType(DeviceType.myBodyPlus)
    }
    static var isConnectMyBracelet: Bool {
        return DBManager.sharedInstance.haveConnectedWithType(DeviceType.bracelet)
    }
    
    static func removeDeviceBind(_ type: DeviceType) {
        DBManager.sharedInstance.removeDeviceBind(type)
    }
    
    static func sendFeedBack(_ feedback: String?, complete: @escaping (_ error: NSError?) -> Void) {
        
        if feedback == nil || feedback == "" {
            complete(NSError(domain: "用户反馈错误", code: 1, userInfo: [NSLocalizedDescriptionKey : "反馈内容不能为空"]))
            return
        }
        
        UserRequest.feedBack(UserData.sharedInstance.userId!, feedback: feedback!) { (error: NSError?) -> Void in
            complete(error)
        }
    }
    
    /*
        每搜索到一个设备会回调一次,返回所有搜索到的设备信息
        {
            “name” : "设备名称",
            "UUID" : "唯一ID"
        }
    */
    static func searchDevice(_ type: DeviceType, complete: (_ deviceList: [[String: String]]) -> Void) {
        if type == .myBody {
            
        }
        else if type == .myBodyMini || type == .myBodyPlus {
            
        }
        else if type == .bracelet {
            
        }
    }
    
    static func isBindDevice(_ types: [DeviceType]) -> Bool {
        for type in types {
            let have = DBManager.sharedInstance.haveConnectedWithType(type)
            if have {
                return have
            }
        }
        
        return false
    }
    
    static func bindDevice(_ device: DeviceManagerProtocol) {
        DBManager.sharedInstance.addDevice(device.uuid, name: device.name, type: device.type)
    }
    
    static func unBindDevice(_ types: [DeviceType]) {
        for type in types {
            DBManager.sharedInstance.removeDeviceBind(type)
        }
    }
    
    static func addLocalNotification() {
        let notification = UILocalNotification()
        
        notification.fireDate = Date().zeroTime().addingTimeInterval(20 * 60 * 60)
        notification.repeatInterval = NSCalendar.Unit.day
        notification.alertBody = "今天身体测试时间到！"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    static func removeLocalNotification() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
