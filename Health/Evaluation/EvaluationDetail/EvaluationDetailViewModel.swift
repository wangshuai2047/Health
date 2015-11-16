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
    var scaleResult: ScaleResultProtocol
    var timeShowString: String
    
    init(info: [String: AnyObject]) {
        
        let gender: Bool
        let age: UInt8
        let height: UInt8
        let userId = (info["userId"] as! NSNumber).integerValue
        if let userInfo = DBManager.shareInstance().queryUser(userId) {
            gender = (userInfo["gender"] as! NSNumber).boolValue
            age = (userInfo["age"] as! NSNumber).unsignedCharValue
            height = (userInfo["height"] as! NSNumber).unsignedCharValue
        }
        else {
            gender = UserManager.mainUser.gender
            age = UserManager.mainUser.age
            height = UserManager.mainUser.height
        }
        
        scaleResult = ScaleResultProtocolCreate(info, gender: gender, age: age, height: height)
        timeShowString = (info["timeStamp"] as! NSDate).currentZoneFormatDescription()
    }
}