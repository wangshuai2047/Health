//
//  ScoreRequestTests.swift
//  Health
//
//  Created by Yalin on 15/9/7.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class ScoreRequestTests: XCTestCase {

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
    
    func test_ScoreRequest_queryScore_isSucess() {
        let expectation = expectationWithDescription("test_ScoreRequest_queryScore_isSucess")
        
        ScoreRequest.queryScore(1234, complete: { (score: Float?, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_ScoreRequest_queryScore_isSucess 错误: \(error?.description)")
        })
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
//            XCTFail("请求超时")
        })
    }

    func test_ScoreRequest_share_isSucess() {
        let expectation = expectationWithDescription("")
        
        ScoreRequest.share(1234, type: 1, platform: ThirdPlatformType.Weibo) { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_ScoreRequest_queryScore_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
//            XCTFail("请求超时")
        })
    }
}
