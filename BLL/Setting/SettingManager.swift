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
        return DBManager.shareInstance().haveConnectedWithType(DeviceType.MyBody)
    }
    static var isConnectMyBodyMini: Bool {
        return DBManager.shareInstance().haveConnectedWithType(DeviceType.MyBodyMini)
    }
    static var isConnectMyBodyPlus: Bool {
        return DBManager.shareInstance().haveConnectedWithType(DeviceType.MyBodyPlus)
    }
    static var isConnectMyBracelet: Bool {
        return DBManager.shareInstance().haveConnectedWithType(DeviceType.Bracelet)
    }
    
    static func removeDeviceBind(type: DeviceType) {
        DBManager.shareInstance().removeDeviceBind(type)
    }
    
    static func sendFeedBack(feedback: String?, complete: (error: NSError?) -> Void) {
        
        if feedback == nil || feedback == "" {
            complete(error: NSError(domain: "用户反馈错误", code: 1, userInfo: [NSLocalizedDescriptionKey : "反馈内容不能为空"]))
            return
        }
        
        UserRequest.feedBack(UserData.shareInstance().userId!, feedback: feedback!) { (error: NSError?) -> Void in
            complete(error: error)
        }
    }
    
    /*
        每搜索到一个设备会回调一次,返回所有搜索到的设备信息
        {
            “name” : "设备名称",
            "UUID" : "唯一ID"
        }
    */
    static func searchDevice(type: DeviceType, complete: (deviceList: [[String: String]]) -> Void) {
        if type == .MyBody {
            
        }
        else if type == .MyBodyMini || type == .MyBodyPlus {
            
        }
        else if type == .Bracelet {
            
        }
    }
    
    static func bindDevice(device: DeviceManagerProtocol) {
        DBManager.shareInstance().addDevice(device.uuid, name: device.name, type: device.type)
    }
    
    static func unBindDevice(type: DeviceType) {
        DBManager.shareInstance().removeDeviceBind(type)
    }
}