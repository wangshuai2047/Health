//
//  MyBodyResult.swift
//  Health
//
//  Created by Yalin on 15/10/10.
//  Copyright © 2015年 Yalin. All rights reserved.
//

import Foundation

struct MyBodyResult: ScaleResultProtocol {
    
    var dataId: String
    var userId: Int
    
    // true 男 false 女
    var gender: Bool
    var age: UInt8
    var height: UInt8
    
    // 体重
    var weight: Float
    // 水分率
    var waterPercentage: Float
    // 内脏脂肪率
    var visceralFatPercentage: Float
    
    // 体脂率
    var fatPercentage: Float
    // 脂肪重
    var fatWeight: Float
    // 水分重
    var waterWeight: Float
    // 肌肉重
    var muscleWeight: Float
    // 蛋白质重
    var proteinWeight: Float
    // 骨重
    var boneWeight: Float
    // 骨骼肌
    var boneMuscleWeight: Float
    
    
    init(userId: Int, gender: Bool, age: UInt8, height: UInt8, weight: Float, waterContent: Float, visceralFatContent: Float, fatPercentage: Float, fatWeight: Float, waterWeight: Float, muscleWeight: Float, proteinWeight: Float, boneWeight: Float, boneMuscleWeight: Float) {
        dataId = NSUUID().UUIDString
        
        self.userId = userId
        self.gender = gender
        self.age = age
        self.height = height
        
        self.weight = weight
        self.waterPercentage = waterContent
        self.visceralFatPercentage = visceralFatContent
        
        self.fatPercentage = fatPercentage
        self.fatWeight = fatWeight
        self.waterWeight = waterWeight
        self.muscleWeight = muscleWeight
        self.proteinWeight = proteinWeight
        self.boneWeight = boneWeight
        self.boneMuscleWeight = boneMuscleWeight
    }
    
    static func scaleInputData(weight: Float, waterContent: Float, visceralFatContent: Float, gender: Bool, userId: Int, age: UInt8, height: UInt8) -> ScaleResultProtocol {
        
        /*
        从四点极称中，我们只需要三项数据：水分率、内脏脂肪率和体重
        水分率为a%，体脂率为p%，体重为W，身高为h，年龄为age
        身体评分和身体年龄的公式已经给
        
        体脂率（男）       p% =（1-((a%*100)/73.81)+(0.6/W)）*100-1
        女               p% =（1-((a%*100)/73.81)+(0.6/W)）*100+1
        
        脂肪重 F=W*p%
        水分重 a=W*a%
        肌肉重 S=a/0.78
        蛋白质重 M=S-a
        骨重 B=W-F-S
        */
        
        let gender = UserData.shareInstance().gender!
        
        // 体脂率
        var fatPercentage = (1 - ((waterContent)/73.81) + (0.6 / weight)) * 100 - 1 // 男
        if gender == false {
            fatPercentage += 2 // 女
        }
        
        // 脂肪重
        let fatWeight = weight * fatPercentage / 100
        // 水分重
        let waterWeight = weight * waterContent / 100
        // 肌肉重
        let muscleWeight = waterWeight / 0.78
        // 蛋白质重
        let proteinWeight =  muscleWeight - waterWeight
        // 骨重
        let boneWeight = weight - fatWeight - muscleWeight
        // 骨骼肌重
        let boneMuscleWeight = muscleWeight * 0.7135
        
        let result = MyBodyResult(userId: userId, gender: gender, age: age, height: height, weight: weight, waterContent: waterContent, visceralFatContent: visceralFatContent, fatPercentage: fatPercentage, fatWeight: fatWeight, waterWeight: waterWeight, muscleWeight: muscleWeight, proteinWeight: proteinWeight, boneWeight: boneWeight, boneMuscleWeight: boneMuscleWeight)
        
        return result
    }
}

extension MyBodyResult {
    
    init(info: [String: AnyObject]) {
        
        dataId = info["dataId"] as! String
        userId = (info["userId"] as! NSNumber).integerValue
        weight = (info["weight"] as! NSNumber).floatValue
        waterPercentage = (info["waterPercentage"] as! NSNumber).floatValue
        visceralFatPercentage = (info["visceralFatPercentage"] as! NSNumber).floatValue
        fatPercentage = (info["fatPercentage"] as! NSNumber).floatValue
        fatWeight = (info["fatWeight"] as! NSNumber).floatValue
        waterWeight = (info["waterWeight"] as! NSNumber).floatValue
        muscleWeight = (info["muscleWeight"] as! NSNumber).floatValue
        proteinWeight = (info["proteinWeight"] as! NSNumber).floatValue
        boneWeight = (info["boneWeight"] as! NSNumber).floatValue
        boneMuscleWeight = (info["boneMuscleWeight"] as! NSNumber).floatValue
        
        gender = UserData.shareInstance().gender!
        age = UserData.shareInstance().age!
        height = UserData.shareInstance().height!
    }
    
    init(evaluationdata: EvaluationData) {
        
        dataId = evaluationdata.valueForKey("dataId") as! String
        userId = (evaluationdata.valueForKey("userId") as! NSNumber).integerValue
        weight = (evaluationdata.valueForKey("weight") as! NSNumber).floatValue
        waterPercentage = (evaluationdata.valueForKey("waterPercentage") as! NSNumber).floatValue
        visceralFatPercentage = (evaluationdata.valueForKey("visceralFatPercentage") as! NSNumber).floatValue
        fatPercentage = (evaluationdata.valueForKey("fatPercentage") as! NSNumber).floatValue
        fatWeight = (evaluationdata.valueForKey("fatWeight") as! NSNumber).floatValue
        waterWeight = (evaluationdata.valueForKey("waterWeight") as! NSNumber).floatValue
        muscleWeight = (evaluationdata.valueForKey("muscleWeight") as! NSNumber).floatValue
        proteinWeight = (evaluationdata.valueForKey("proteinWeight") as! NSNumber).floatValue
        boneWeight = (evaluationdata.valueForKey("boneWeight") as! NSNumber).floatValue
        boneMuscleWeight = (evaluationdata.valueForKey("boneMuscleWeight") as! NSNumber).floatValue
        
        gender = UserData.shareInstance().gender!
        age = UserData.shareInstance().age!
        height = UserData.shareInstance().height!
    }
}