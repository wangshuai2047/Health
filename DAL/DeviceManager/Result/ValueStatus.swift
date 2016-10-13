//
//  ValueStatus.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

enum ValueStatus {
    case low    // 偏低
    case normal // 正常
    case high   // 偏高
    
    init(value: Float, low: Float, high: Float) {
        if value > high {
            self = .high
        }
        else if value < low {
            self = .low
        }
        else {
            self = .normal
        }
    }
    
    var statusColor: UIColor {
        switch self {
        case .low:
            return UIColor(red: 235/255.0, green: 189/255.0, blue: 72/255.0, alpha: 1)
        case .normal:
            return UIColor(red: 118/255.0, green: 218/255.0, blue: 66/255.0, alpha: 1)
        case .high:
            return UIColor(red: 211/255.0, green: 46/255.0, blue: 55/255.0, alpha: 1)
        }
    }
}
