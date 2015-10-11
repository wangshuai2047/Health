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