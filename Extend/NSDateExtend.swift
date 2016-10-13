//
//  NSDateExtend.swift
//  Health
//
//  Created by Yalin on 15/9/6.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

extension Date {
    // 获取零点时间
    func zeroTime() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let nowDateString = dateFormatter.string(from: self)
        let date = dateFormatter.date(from: nowDateString)
        
        return date!
    }
    
    func secondTimeInteval() -> Int {
        return Int(self.timeIntervalSince1970)
    }
    
    func currentZoneFormatDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func YYdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd"
        return dateFormatter.string(from: self)
    }
    
    // 获取小时数
    
}
