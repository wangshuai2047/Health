//
//  ConvertString.swift
//  Health
//
//  Created by Yalin on 15/8/29.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var UInt8Value: UInt8 {
        return UInt8((self as NSString).integerValue)
    }
}