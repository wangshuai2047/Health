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
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func test_evaluationRequest_queryDatas_isSucess() {
        let expectation = expectationWithDescription("test_evaluationRequest_queryDatas_isSucess")
        
        EvaluationRequest.queryEvaluationDatas(1234, startDate: NSDate(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: NSDate()) { (datas, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_evaluationRequest_queryDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_evaluationRequest_uploadDatas_isSucess() {
        let expectation = expectationWithDescription("test_evaluationRequest_uploadDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 1234,
            "boneWeight" : 20,
            "fatPercentage" : 0.2,
            "muscleWeight" : 40,
            "proteinWeight" : 12,
            "visceralFatPercentage" : 4,
            "waterPercentage" : 0.15,
            "waterWeight" : 13,
            "weight" : 59,
            "timestamp" : NSDate().secondTimeInteval()
            ])
        
        EvaluationRequest.uploadEvaluationDatas(datas) { (info, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_evaluationRequest_uploadDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_evaluationRequest_deleteData_isSucess() {
        
        let expectation = expectationWithDescription("test_evaluationRequest_deleteData_isSucess")
        
        EvaluationRequest.deleteEvaluationData("123", userId: 1234) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_evaluationRequest_deleteData_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
        
        
    }
    
    func test_evaluationRequest_deleteDatas_isSucess() {
        
        let expectation = expectationWithDescription("test_evaluationRequest_deleteDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 1234,
            "dataId" : "123"
            ])
        
        EvaluationRequest.deleteEvaluationDatas(datas) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_evaluationRequest_deleteDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
        
        
    }
}
