//
//  GoalManager.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit

struct GoalManager {
    static func isConnectDevice() -> Bool {
        return DBManager.shareInstance().haveConnectedBracelet
    }
    
    static func lastEvaluationData() -> ScaleResult? {
        if let info = DBManager.shareInstance().queryLastEvaluationData(UserData.shareInstance().userId!) {
            return ScaleResult(info: info)
        }
        
        return nil
    }
    
    static func currentGoalInfo() -> GoalShowInfo? {
        if let result = GoalManager.lastEvaluationData() {
            return GoalShowInfo(scaleResult: result, sevenDaysDatas: querySevenDaysData())
        }
        
        return nil
    }
    
    static func syncDatas(complete: ((NSError?) -> Void)) {
        
        var startTime: NSDate
        var lastGoalData = DBManager.shareInstance().queryLastGoalData()
        if lastGoalData == nil {
            startTime = NSDate().dateByAddingTimeInterval(-30 * 24 * 60 * 60)
        }
        else {
            startTime = lastGoalData!["endTime"] as! NSDate
        }
        
        startTime = NSDate()
        
        DeviceManager.shareInstance().syncBraceletDatas(startTime, syncComplete: { (list: [BraceletResult], error: NSError?) -> Void in
            
            if error == nil {
                for result in list {
                    // 插入数据库
                    DBManager.shareInstance().addGoalData({ (inout setDatas: GoalData) -> GoalData in
                        
                        setDatas.dataId = result.dataId
                        setDatas.userId = NSNumber(unsignedShort: result.userId)
                        setDatas.isUpload = false
                        
                        setDatas.startTime = result.startTime
                        setDatas.endTime = result.endTime
                        setDatas.steps = NSNumber(unsignedShort: result.steps)
                        setDatas.stepsType = NSNumber(unsignedShort: result.stepsType.rawValue)
                        
                        return setDatas;
                    })
                }
                
                refreshSevenDaysData()
            }
            
            complete(error)
        })
    }
    
    static var isSetGoal: Bool {
        if UserGoalData.type == .None {
            return false
        }
        else {
            return true
        }
    }
    
    static func setGoal(type: UserGoalData.GoalType, number: Int?, days: Int?) {
        UserGoalData.type = type
        UserGoalData.number = number
        UserGoalData.days = days
        UserGoalData.setDate = NSDate()
    }
    
    private static var sevenDaysData: [(UInt16,UInt16,UInt16,UInt16)] = []
    
    static func refreshSevenDaysData() {
        var queryDatas: [(UInt16,UInt16,UInt16,UInt16)] = []
        
        // 获取7天数据从今天开始
        let now = NSDate(timeIntervalSinceNow: 24 * 60 * 60)
        var beginDate = now.zeroTime()
        
        for _ in 0...6 {
            
            let endDate = beginDate.dateByAddingTimeInterval(-24 * 60 * 60)
            let list = DBManager.shareInstance().queryGoalData(endDate, endDate: beginDate)
            beginDate = endDate
            
            var walkStep: UInt16 = 0
            var runStep: UInt16 = 0
            var results: [BraceletResult] = []
            
            // 计算走步时间
            for data in list {
                let result = BraceletResult(info: data)
                results.append(result)
                
                if result.stepsType == .Walk // 走路
                {
                    walkStep += result.steps
                }
                else if result.stepsType == .Run // 跑步
                {
                    runStep += result.steps
                }
            }
            
            let (sleepTime, deepSleepTime) = parseOneDaySleepDatas(results)
            
            queryDatas += [(walkStep,runStep,sleepTime,deepSleepTime)]
        }
        
        GoalManager.sevenDaysData = queryDatas;
    }
    
    static func querySevenDaysData() -> [(UInt16,UInt16,UInt16,UInt16)] {
        
        if GoalManager.sevenDaysData.count == 0 {
            refreshSevenDaysData()
        }
        
        return GoalManager.sevenDaysData
    }
    
    // 获取过去七天平均值
    static func querySevenDaysAverageValues() -> (Int, Int) {
        var averageValues = (0,0)
        
        for (walkStep,_,sleepTime,deepSleepTime) in GoalManager.querySevenDaysData() {
            averageValues.0 += Int(walkStep)
            averageValues.1 += Int(sleepTime)
            averageValues.1 += Int(deepSleepTime)
        }
        
        averageValues.0 /= 7
        averageValues.0 /= 7
        
        return averageValues
    }
}

extension BraceletResult {
    init(info: [String: NSObject]) {
        
        self.dataId = info["dataId"] as! String
        self.userId = (info["userId"] as! NSNumber).unsignedShortValue
        
        self.startTime = info["startTime"] as! NSDate
        self.endTime = info["endTime"] as! NSDate
        self.steps = (info["steps"] as! NSNumber).unsignedShortValue
        self.stepsType = StepsType(rawValue: (info["stepsType"] as! NSNumber).unsignedShortValue)!
    }
}

extension GoalManager {
    
    // 返回(浅睡眠分钟数, 深睡眠分钟数)
    static func parseOneDaySleepDatas(datas: [BraceletResult]) -> (UInt16, UInt16) {
        
        var sleepStarted = false
        var sleepStartTime: NSTimeInterval = 0
        var sleepEndTime: NSTimeInterval = 0
        var deepSleepMinutes = 0
        var walkMinutes = 0
        var todayDone = false
        var wakeupDataCnt = 0
        
        let sleep_end_hour = 11  // 早上11点
        let sleep_start_hour = 20 // 晚上8点
        
        let cal = NSCalendar.currentCalendar()
        
        for data in datas {
            let dateComponents = cal.components(NSCalendarUnit.Hour, fromDate: data.startTime)
            let hour = dateComponents.hour
            
            // 判断发生情况的小时是否在规定的时段内 早上11点 到晚上20点
            if hour >= sleep_end_hour && hour < sleep_start_hour {
                continue
            }
            
            // 还没有开始解析数据
            if !sleepStarted {
                if data.stepsType != BraceletResult.StepsType.Sleep {continue}
                if data.endTime.timeIntervalSinceDate(data.startTime) < 20 * 60 {continue} // 小于20分钟
                if data.steps == 0 {continue}
                if NSTimeInterval(data.steps) * 9 * 60 / (data.endTime.timeIntervalSinceDate(data.startTime)) >= 2 {continue}
                if data.endTime.timeIntervalSinceDate(data.startTime) / 60 / 60 >= 2 {continue} // 判断两个小时内如果没动的话 就不是睡眠
                
                // 记录数据 开始睡眠
                sleepStarted = true
                sleepStartTime = data.startTime.timeIntervalSince1970
                sleepEndTime = data.endTime.timeIntervalSince1970
                deepSleepMinutes = 0
                walkMinutes = 0
                todayDone = false
                wakeupDataCnt = 0
            }
            else {
                // 睡眠结束判断
                if (data.stepsType != .Sleep && data.endTime.timeIntervalSinceDate(data.startTime) > 2 * 60)
                 ||
                ((data.stepsType == .Sleep && data.endTime.timeIntervalSinceDate(data.startTime) > 10 * 60) && (NSTimeInterval(data.steps) * 60 / data.endTime.timeIntervalSinceDate(data.startTime)) > 2)
                    ||
                wakeupDataCnt >= 5
                {
                    // 睡眠结束 但是晚上时间还很长  半夜2点
                    if ((hour < 23 && hour >= sleep_start_hour) || (hour < 2)) {
                        sleepStarted = false
                        sleepStartTime = 0
                        sleepStartTime = 0
                        deepSleepMinutes = 0
                        walkMinutes = 0
                        todayDone = false
                        wakeupDataCnt = 0
                    }
                    else { // 睡眠真正的结束了
                        sleepEndTime = data.startTime.timeIntervalSince1970
                        
                        // 浅睡眠
                        let liteSleepMinutes = (sleepEndTime - sleepStartTime + 60 - 0.001) / 60
                        
                        
                        print("浅睡眠: \(liteSleepMinutes)分钟   深睡眠: \(deepSleepMinutes)分钟")
                        return (UInt16(liteSleepMinutes), UInt16(deepSleepMinutes))
                        
//                        sleepStarted = false
//                        sleepStartTime = 0
//                        sleepStartTime = 0
//                        deepSleepMinutes = 0
//                        walkMinutes = 0
//                        todayDone = true
//                        wakeupDataCnt = 0
                    }
                }
                else {  // 睡眠未结束
                    if todayDone {continue}
                    
                    // 在走路 可能是去WC
                    if (data.stepsType != .Sleep) {
                        ++wakeupDataCnt
                        walkMinutes += Int((data.endTime.timeIntervalSinceDate(data.startTime) + 60 - 0.001) / 60)
                    }
                    else if data.endTime.timeIntervalSinceDate(data.startTime) > 5 && NSTimeInterval(data.steps * 60) / data.endTime.timeIntervalSinceDate(data.startTime) > 1 {
                        ++wakeupDataCnt
                    }
                    else if data.endTime.timeIntervalSinceDate(data.startTime) > 20 * 60 && NSTimeInterval(data.steps * 25 * 60) / data.endTime.timeIntervalSinceDate(data.startTime) <= 2 {
                        wakeupDataCnt = 0
//                        deepSleepMinutes +=
                    }
                    else {
                        wakeupDataCnt = 0
                    }
                    sleepEndTime = data.endTime.timeIntervalSince1970
                }
            }
        }
        
        if sleepStarted {
            // 睡眠未结束  需要继续监听数据
            // 浅睡眠
            let liteSleepMinutes = (sleepEndTime - sleepStartTime + 60 - 0.001) / 60
            print("浅睡眠: \(liteSleepMinutes)分钟   深睡眠: \(deepSleepMinutes)分钟")
            return (UInt16(liteSleepMinutes), UInt16(deepSleepMinutes))
        }
        
        return (0, 0)
    }
}
