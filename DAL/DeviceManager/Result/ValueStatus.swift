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
            return UIColor(red: 235/255.0, green: 189/255.0, blue: 72/255.0, alpha: 1)
        case .Normal:
            return UIColor(red: 118/255.0, green: 218/255.0, blue: 66/255.0, alpha: 1)
        case .High:
            return UIColor(red: 211/255.0, green: 46/255.0, blue: 55/255.0, alpha: 1)
        }
    }
}