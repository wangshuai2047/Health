//
//  TrendManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct TrendManager {
    static func eightDaysDatas(beginTimescamp: NSDate, endTimescamp: NSDate) -> [[String: AnyObject]] {
        return DBManager.shareInstance().queryEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp, userId: UserManager.shareInstance().currentUser.userId)
    }
}

