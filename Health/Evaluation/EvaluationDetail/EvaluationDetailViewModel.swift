//
//  EvaluationDetailViewModel.swift
//  Health
//
//  Created by Yalin on 15/9/9.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct EvaluationDetailViewModel {
    
     var allDatas: [EvaluationDetailCellViewModel] = []
    
    init() {
        reloadData()
    }
    
    mutating func reloadData() {
        let endDate = NSDate()
        let beginDate = endDate.dateByAddingTimeInterval(-30 * 24 * 60 * 60)
        
        let evaluationDatas = EvaluationManager.mouthDaysDatas(beginDate, endTimescamp: endDate)
        
        allDatas.removeAll(keepCapacity: false)
        for evaluationData in evaluationDatas {
            allDatas += [EvaluationDetailCellViewModel(info: evaluationData)]
        }
    }
}

struct EvaluationDetailCellViewModel {
    var scaleResult: ScaleResult
    var timeShowString: String
    
    init(info: [String: AnyObject]) {
        scaleResult = ScaleResult(info: info)
        timeShowString = (info["timeStamp"] as! NSDate).currentZoneFormatDescription()
    }
}