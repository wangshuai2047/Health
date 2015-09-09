//
//  GoalRequestTests.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class GoalRequestTests: XCTestCase {

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

    func test_goalRequest_queryDatas_isSucess() {
        let expectation = expectationWithDescription("test_goalRequest_queryDatas_isSucess")
        
        GoalRequest.queryGoalDatas(1234, startDate: NSDate(timeIntervalSinceNow: -30 * 24 * 60 * 60), endDate: NSDate()) { (datas, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_goalRequest_queryDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_goalRequest_uploadDatas_isSucess() {
        let expectation = expectationWithDescription("test_goalRequest_uploadDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 1234,
            "steps" : 5,
            "stepsType" : 10,
            "startTime" : NSDate(timeIntervalSinceNow: -30).secondTimeInteval(),
            "endTime" : NSDate().secondTimeInteval()
            ])
        
        GoalRequest.uploadGoalDatas(datas) { (info, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_goalRequest_uploadDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_goalRequest_deleteData_isSucess() {
        let expectation = expectationWithDescription("test_goalRequest_deleteData_isSucess")
        
        GoalRequest.deleteGoalData("12345", userId: 1234) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_goalRequest_deleteData_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_goalRequest_deleteDatas_isSucess() {
        
        let expectation = expectationWithDescription("test_goalRequest_deleteDatas_isSucess")
        
        var datas: [[String : AnyObject]] = []
        
        datas.append([
            "userId" : 1234,
            "dataId" : "123"
            ])
        
        GoalRequest.deleteGoalDatas(datas) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_goalRequest_deleteDatas_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
        
        
    }
}
