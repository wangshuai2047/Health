//
//  Alert.swift
//  Health
//
//  Created by Yalin on 15/8/26.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct Alert {
    static func showErrorAlert(_ title: String?, message: String?) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "确定").show()
    }
    
    static func showError(_ error: NSError) {
        UIAlertView(title: error.domain, message: error.localizedDescription, delegate: nil, cancelButtonTitle: "取消").show()
    }
}
