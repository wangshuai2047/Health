//
//  AdsReqeustTests.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class AdsReqeustTests: XCTestCase {

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

    
    func test_AdsRequest_launchAppAds_isSucess() {
        let expectation = self.expectation(withDescription: "test_AdsRequest_launchAppAds_isSucess")
        
        AdsRequest.queryLaunchAds { (ad, error) -> Void in
            
            expectation.fulfill()
            XCTAssertNil(error, "test_AdsRequest_launchAppAds_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_AdsRequest_activityAds_isSucess() {
        
        let expectation = self.expectation(withDescription: "test_AdsRequest_activityAds_isSucess")
        
        let userId = 10
        
        AdsRequest.queryActivityAds(userId, complete: { (ads, error) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_AdsRequest_activityAds_isSucess 错误: \(error?.description)")
        })
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
        
        
    }
}
