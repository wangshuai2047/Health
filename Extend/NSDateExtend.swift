//
//  NSDateExtend.swift
//  Health
//
//  Created by Yalin on 15/9/6.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

extension NSDate {
    // 获取零点时间
    func zeroTime() -> NSDate {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let nowDateString = dateFormatter.stringFromDate(self)
        let date = dateFormatter.dateFromString(nowDateString)
        
        return date!
    }
    
    func secondTimeInteval() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    func currentZoneFormatDescription() -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(self)
    }
}