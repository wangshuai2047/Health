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
    
    var weightDatas: [Float] = []
    var fatDatas: [Float] = []
    var muscleDatas: [Float] = []
    var waterDatas: [Float] = []
    var proteinDatas: [Float] = []
    
    var dateStrings: [String] = []
    
    var weightRange: (Float, Float) = (0, 0)
    var fatRange: (Float, Float) = (0, 0)
    var muscleRange: (Float, Float) = (0, 0)
    var waterRange: (Float, Float) = (0, 0)
    var proteinRange: (Float, Float) = (0, 0)
    
    let weightColor = UIColor(red: 36/255.0, green: 171/255.0, blue: 232/255.0, alpha: 1)
    let fatColor = UIColor(red: 175/255.0, green: 204/255.0, blue: 92/255.0, alpha: 1)
    let muscleColor = UIColor(red: 229/255.0, green: 153/255.0, blue: 44/255.0, alpha: 1)
    let waterColor = UIColor(red: 36/255.0, green: 82/255.0, blue: 219/255.0, alpha: 1)
    let proteinColor = UIColor(red: 239/255.0, green: 225/255.0, blue: 55/255.0, alpha: 1)
    
    var selectedTag: (Int?, Int?) = (nil, nil)
    
    mutating func eightDaysDatas() -> [TrendCellViewModel] {
        let endDate = NSDate()
        let beginDate = endDate.dateByAddingTimeInterval(-300 * 24 * 60 * 60)
        
        let evaluationDatas = TrendManager.eightDaysDatas(beginDate, endTimescamp: endDate)
        
        allDatas.removeAll(keepCapacity: false)
        for evaluationData in evaluationDatas {
            allDatas += [TrendCellViewModel(info: evaluationData)]
        }
        
        dealShowData()
        
        return allDatas
    }
    
    func chartColor(isLeft: Bool) -> UIColor {
        
        let tag = isLeft ? selectedTag.0 : selectedTag.1
        
        if tag == 1 {
            return weightColor
        }
        else if tag == 2 {
            return fatColor
        }
        else if tag == 3 {
            return muscleColor
        }
        else if tag == 4 {
            return waterColor
        }
        else if tag == 5 {
            return proteinColor
        }
        else {
            return UIColor.grayColor()
        }
    }
    
    func rangeOfSelectTag(tag: Int?) -> (Double, Double) {
        if tag == 1 {
            return (Double(weightRange.0), Double(weightRange.1))
        }
        else if tag == 2 {
            return (Double(fatRange.0), Double(fatRange.1))
        }
        else if tag == 3 {
            return (Double(muscleRange.0), Double(muscleRange.1))
        }
        else if tag == 4 {
            return (Double(waterRange.0), Double(waterRange.1))
        }
        else if tag == 5 {
            return (Double(proteinRange.0), Double(proteinRange.1))
        }
        else {
            return (0,0)
        }
    }
    
    func value(index: Int) -> (Double?, Double?, String) {
        
        var firstValue: Double?
        var secondValue: Double?
        let dateStr: String = dateStrings[index]
        
        if selectedTag.0 == 1 {
            firstValue = Double(weightDatas[index])
        }
        else if selectedTag.0 == 2 {
            firstValue = Double(fatDatas[index])
        }
        else if selectedTag.0 == 3 {
            firstValue = Double(muscleDatas[index])
        }
        else if selectedTag.0 == 4 {
            firstValue = Double(waterDatas[index])
        }
        else if selectedTag.0 == 5 {
            firstValue = Double(proteinDatas[index])
        }
        
        if selectedTag.1 == 1 {
            secondValue = Double(weightDatas[index])
        }
        else if selectedTag.1 == 2 {
            secondValue = Double(fatDatas[index])
        }
        else if selectedTag.1 == 3 {
            secondValue = Double(muscleDatas[index])
        }
        else if selectedTag.1 == 4 {
            secondValue = Double(waterDatas[index])
        }
        else if selectedTag.1 == 5 {
            secondValue = Double(proteinDatas[index])
        }
        
        return (firstValue, secondValue, dateStr)
    }
    
    mutating func dealShowData() {
        
        weightDatas.removeAll()
        fatDatas.removeAll()
        muscleDatas.removeAll()
        waterDatas.removeAll()
        proteinDatas.removeAll()
        dateStrings.removeAll()
        
        
        for var i = 0; i < allDatas.count; i++ {
            if i != 0 && allDatas[i-1].dateString == allDatas[i].dateString {
                
                weightDatas[weightDatas.count-1] = allDatas[i].scaleResult.weight
                fatDatas[fatDatas.count-1] = allDatas[i].scaleResult.fatWeight
                muscleDatas[muscleDatas.count-1] = allDatas[i].scaleResult.muscleWeight
                waterDatas[waterDatas.count-1] = allDatas[i].scaleResult.waterWeight
                proteinDatas[proteinDatas.count-1] = allDatas[i].scaleResult.proteinWeight
            }
            else {
                dateStrings.append(allDatas[i].dateString)
                weightDatas.append(allDatas[i].scaleResult.weight)
                fatDatas.append(allDatas[i].scaleResult.fatWeight)
                muscleDatas.append(allDatas[i].scaleResult.muscleWeight)
                waterDatas.append(allDatas[i].scaleResult.waterWeight)
                proteinDatas.append(allDatas[i].scaleResult.proteinWeight)
            }
        }
        
        var tempDatas = weightDatas.sort()
        if weightDatas.count > 0 {
            weightRange = (tempDatas.first!, tempDatas.last!)
        }
        
        tempDatas = fatDatas.sort()
        if fatDatas.count > 0 {
            fatRange = (tempDatas.first!, tempDatas.last!)
        }
        
        tempDatas = muscleDatas.sort()
        if muscleDatas.count > 0 {
            muscleRange = (tempDatas.first!, tempDatas.last!)
        }
        
        tempDatas = waterDatas.sort()
        if waterDatas.count > 0 {
            waterRange = (tempDatas.first!, tempDatas.last!)
        }
        
        tempDatas = proteinDatas.sort()
        if proteinDatas.count > 0 {
            proteinRange = (tempDatas.first!, tempDatas.last!)
        }
    }
}

struct TrendCellViewModel {
    var scaleResult: ScaleResult
    var timeShowString: String
    var dateString: String
    
    init(info: [String: NSObject]) {
        scaleResult = ScaleResult(info: info)
        timeShowString = (info["timeStamp"] as! NSDate).description
        dateString = (info["timeStamp"] as! NSDate).YYdd()
    }
}

