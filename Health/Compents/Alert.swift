//
//  Alert.swift
//  Health
//
//  Created by Yalin on 15/8/26.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct Alert {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    static func showErrorAlert(title: String?, message: String?) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "取消").show()
    }
}