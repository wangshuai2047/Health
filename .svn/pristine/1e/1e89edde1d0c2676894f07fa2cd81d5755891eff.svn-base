//
//  HealthDataHelper.swift
//  Health
//
//  Created by Yalin on 15/10/17.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import UIKit

class HealthDataHelper: NSObject {
    
    // 返回(走路,跑步,浅睡眠分钟数, 深睡眠分钟数, 睡眠开始时间, 睡眠结束时间)
    static func parseOneDaySportDatas(_ datas: [[String: AnyObject]]) -> (Int, Int, Int, Int, Date, Date) {
        
        var walkStep: Int = 0
        var runStep: Int = 0
        var results: [BraceletData] = []
        
        // 计算走步时间
        for data in datas {
            let result = BraceletData(info: data)
            results.append(result)
            
            if result.stepsType == .walk // 走路
            {
                walkStep += Int(result.steps)
            }
            else if result.stepsType == .run // 跑步
            {
                runStep += Int(result.steps)
            }
        }
        
        let (sleepTime, deepSleepTime, sleepStartDate, sleepEndDate) = parseOneDaySleepDatas(results)
        
        return (walkStep, runStep, sleepTime, deepSleepTime, sleepStartDate, sleepEndDate)
    }
    
    // 返回(浅睡眠分钟数, 深睡眠分钟数, 睡眠开始时间, 睡眠结束时间)
    fileprivate static func parseOneDaySleepDatas(_ datas: [BraceletData]) -> (Int, Int, Date, Date) {
        
        var sleepStarted = false
        var sleepStartTime: TimeInterval = 0
        var sleepEndTime: TimeInterval = 0
        var deepSleepMinutes = 0
        var walkMinutes = 0
        var todayDone = false
        var wakeupDataCnt = 0
        
        let sleep_end_hour = 11  // 早上11点
        let sleep_start_hour = 20 // 晚上8点
        
        let cal = Calendar.current
        
        for data in datas {
            let dateComponents = (cal as NSCalendar).components(NSCalendar.Unit.hour, from: data.startTime)
            let hour = dateComponents.hour
            
            // 判断发生情况的小时是否在规定的时段内 早上11点 到晚上20点
            if hour! >= sleep_end_hour && hour! < sleep_start_hour {
                continue
            }
            
            // 还没有开始解析数据
            if !sleepStarted {
                if data.stepsType != StepsType.sleep {continue}
                if data.endTime.timeIntervalSince(data.startTime) < 20 * 60 {continue} // 小于20分钟
                if data.steps == 0 {continue}
                if TimeInterval(data.steps) * 9 * 60 / (data.endTime.timeIntervalSince(data.startTime)) >= 2 {continue}
                if data.endTime.timeIntervalSince(data.startTime) / 60 / 60 >= 2 {continue} // 判断两个小时内如果没动的话 就不是睡眠
                
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
                if (data.stepsType != .sleep && data.endTime.timeIntervalSince(data.startTime) > 2 * 60)
                    ||
                    ((data.stepsType == .sleep && data.endTime.timeIntervalSince(data.startTime) > 10 * 60) && (TimeInterval(data.steps) * 60 / data.endTime.timeIntervalSince(data.startTime)) > 2)
                    ||
                    wakeupDataCnt >= 5
                {
                    // 睡眠结束 但是晚上时间还很长  半夜2点
                    if ((hour! < 23 && hour! >= sleep_start_hour) || (hour! < 2)) {
                        sleepStarted = false
                        sleepStartTime = 0
                        sleepEndTime = 0
                        deepSleepMinutes = 0
                        walkMinutes = 0
                        todayDone = false
                        wakeupDataCnt = 0
                    }
                    else { // 睡眠真正的结束了
                        sleepEndTime = data.startTime.timeIntervalSince1970
                        
                        // 浅睡眠
                        let sleepMinutes = (sleepEndTime - sleepStartTime + 60 - 0.001) / 60
                        
                        print("浅睡眠: \(Int(sleepMinutes) - deepSleepMinutes)分钟   深睡眠: \(deepSleepMinutes)分钟")
                        return (Int(sleepMinutes) - deepSleepMinutes, Int(deepSleepMinutes), Date(timeIntervalSince1970: sleepStartTime), Date(timeIntervalSince1970: sleepEndTime))
                        
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
                    
                    
                    let a = data.endTime.timeIntervalSince(data.startTime)
                    let b = TimeInterval(data.steps * 25 * 60) / data.endTime.timeIntervalSince(data.startTime)
                    
                    // 在走路 可能是去WC
                    if (data.stepsType != .sleep) {
                        wakeupDataCnt += 1
                        walkMinutes += Int((data.endTime.timeIntervalSince(data.startTime) + 60 - 0.001) / 60)
                    }
                    else if data.endTime.timeIntervalSince(data.startTime) > 5 && TimeInterval(data.steps * 60) / data.endTime.timeIntervalSince(data.startTime) > 1 {
                        wakeupDataCnt += 1
                        
                    } // Expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
                    else if a > 20 * 60 && b <= 2 {
                        wakeupDataCnt = 0
                        deepSleepMinutes += Int(sleepEndTime - sleepStartTime) / 60
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
            let sleepMinutes = (sleepEndTime - sleepStartTime + 60 - 0.001) / 60
            print("浅睡眠: \(Int(sleepMinutes) - deepSleepMinutes)分钟   深睡眠: \(deepSleepMinutes)分钟")
            return (Int(sleepMinutes) - deepSleepMinutes, Int(deepSleepMinutes), Date(timeIntervalSince1970: sleepStartTime), Date(timeIntervalSince1970: sleepEndTime))
        }
        
        return (0, 0, Date(timeIntervalSince1970: sleepStartTime), Date(timeIntervalSince1970: sleepEndTime))
    }
}
