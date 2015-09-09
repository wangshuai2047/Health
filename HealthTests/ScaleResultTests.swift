//
//  ScaleResultTests.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class ScaleResultTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func test_scale_scaleResult_result() {
        
        let result = ScaleOld.scaleInputData(58, waterContent: 62.5, visceralFatContent: 4, gender: true, userId: 111, age: 25, height: 168)
        
        println("体脂率:\(result.fatPercentage)")
        println("脂肪重:\(result.fatWeight)")
        println("水分重:\(result.waterWeight)")
        println("肌肉重:\(result.muscleWeight)")
        println("蛋白质重:\(result.proteinWeight)")
        println("骨重:\(result.boneWeight)")
        println("骨骼肌重:\(result.fatWeight)")
        println("基础代谢重:\(result.BMR)")
        println("体质指数:\(result.bmi)")
        println("标准体重:\(result.SW)")
        println("去脂体重:\(result.LBM)")
        println("脂肪控制:\(result.fatControl)")
        println("标准肌肉:\(result.m_smm)")
        println("肌肉控制量:\(result.muscleControl)")
        println("分数:\(result.score)")
    }
}
