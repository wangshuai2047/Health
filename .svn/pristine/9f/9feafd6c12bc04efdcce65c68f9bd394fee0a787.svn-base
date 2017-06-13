//
//  EvaluationRequstTests.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class EvaluationRequstTests: XCTestCase {

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
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

    func test_evaluationRequest_queryDatas_isSucess() {
        let expectation = self.expectation(description: "test_evaluationRequest_queryDatas_isSucess")
        
        EvaluationRequest.queryEvaluationDatas(10, startDate: Date(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: Date()) { (datas, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_evaluationRequest_queryDatas_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(timeout: 15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_evaluationRequest_uploadDatas_isSucess() {
        let expectation = self.expectation(withDescription: "test_evaluationRequest_uploadDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 10,
            "boneWeight" : 20,
            "boneMuscleWeight" : 30,
            "fatPercentage" : 0.2,
            "fatWeight" : 20,
            "muscleWeight" : 40,
            "proteinWeight" : 12,
            "visceralFatPercentage" : 4,
            "waterPercentage" : 0.15,
            "waterWeight" : 13,
            "weight" : 59,
            "timestamp" : Date().secondTimeInteval()
            ])
        
        datas.append([
            "userId" : 10,
            "boneWeight" : 21,
            "boneMuscleWeight" : 30,
            "fatPercentage" : 0.2,
            "fatWeight" : 20,
            "muscleWeight" : 40,
            "proteinWeight" : 12,
            "visceralFatPercentage" : 4,
            "waterPercentage" : 0.15,
            "waterWeight" : 13,
            "weight" : 59,
            "timestamp" : Date().secondTimeInteval()
            ])
        
        EvaluationRequest.uploadEvaluationDatas(UserManager.mainUser.userId, datas: datas) { (info, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_evaluationRequest_uploadDatas_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_evaluationRequest_deleteData_isSucess() {
        
        let expectation = self.expectation(withDescription: "test_evaluationRequest_deleteData_isSucess")
        
        EvaluationRequest.deleteEvaluationData("8", userId: 10) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_evaluationRequest_deleteData_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
        
        
    }
    
    func test_evaluationRequest_deleteDatas_isSucess() {
        
        let expectation = self.expectation(withDescription: "test_evaluationRequest_deleteDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 10,
            "dataId" : "11"
            ])
        
        datas.append([
            "userId" : 10,
            "dataId" : "10"
            ])
        
        EvaluationRequest.deleteEvaluationDatas(datas) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_evaluationRequest_deleteDatas_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
        
        
    }
}
