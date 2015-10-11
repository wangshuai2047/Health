//
//  ValueStatus.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

enum ValueStatus {
    case Low    // 偏低
    case Normal // 正常
    case High   // 偏高
    
    init(value: Float, low: Float, high: Float) {
        if value > high {
            self = .High
        }
        else if value < low {
            self = .Low
        }
        else {
            self = .Normal
        }
    }
    
    var statusColor: UIColor {
        switch self {
        case .Low:
            return UIColor.brownColor()
        case .Normal:
            return UIColor.greenColor()
        case .High:
            return UIColor.redColor()
        }
    }
}