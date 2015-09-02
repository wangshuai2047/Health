//
//  TrendViewModel.swift
//  Health
//
//  Created by Yalin on 15/9/1.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct TrendViewModel {
    var allDatas: [TrendCellViewModel] = []
    
    mutating func eightDaysDatas() -> [TrendCellViewModel] {
        let endDate = NSDate()
        let beginDate = endDate.dateByAddingTimeInterval(-30 * 24 * 60 * 60)
        
        let evaluationDatas = TrendManager.eightDaysDatas(beginDate, endTimescamp: endDate)
        
        allDatas.removeAll(keepCapacity: false)
        for evaluationData in evaluationDatas {
            allDatas += [TrendCellViewModel(info: evaluationData)]
        }
        
        return allDatas
    }
}

struct TrendCellViewModel {
    var scaleResult: ScaleResult
    var timeShowString: String
    
    init(info: [String: NSObject]) {
        scaleResult = ScaleResult(info: info)
        timeShowString = (info["timeStamp"] as! NSDate).description
    }
}

