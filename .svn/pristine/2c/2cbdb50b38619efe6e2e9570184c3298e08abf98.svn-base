//
//  TrendManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import Foundation

struct TrendManager {
    static func eightDaysDatas(_ beginTimescamp: Date, endTimescamp: Date) -> [[String: AnyObject]] {
        return DBManager.sharedInstance.queryEvaluationDatas(beginTimescamp, endTimescamp: endTimescamp, userId: UserManager.sharedInstance.currentUser.userId)
    }
}

