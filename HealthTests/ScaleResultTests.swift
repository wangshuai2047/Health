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
        
        print("体脂率:\(result.fatPercentage)")
        print("脂肪重:\(result.fatWeight)")
        print("水分重:\(result.waterWeight)")
        print("肌肉重:\(result.muscleWeight)")
        print("蛋白质重:\(result.proteinWeight)")
        print("骨重:\(result.boneWeight)")
        print("骨骼肌重:\(result.fatWeight)")
        print("基础代谢重:\(result.BMR)")
        print("体质指数:\(result.bmi)")
        print("标准体重:\(result.SW)")
        print("去脂体重:\(result.LBM)")
        print("脂肪控制:\(result.fatControl)")
        print("标准肌肉:\(result.m_smm)")
        print("肌肉控制量:\(result.muscleControl)")
        print("分数:\(result.score)")
    }
}
