//
//  GoalManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct GoalManager {
    static func isConnectDevice() -> Bool {
        return true
    }
    
    static func syncDatas() {
        DeviceManager.shareInstance().syncBraceletDatas()
    }
}
