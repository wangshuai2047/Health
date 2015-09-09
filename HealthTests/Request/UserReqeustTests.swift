//
//  UserReqeustTests.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class UserReqeustTests: XCTestCase {

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

    func test_UserRequest_CompleteInfo_isSuccess() {
        
        let expectation = expectationWithDescription("test_UserRequest_CompleteInfo_isSuccess")
        
        let userId: Int = 1234
        let gender: Bool = true
        let height: UInt8 = 168
        let age: UInt8 = 25
        let name: String = "Me"
        let phone: String = "18610729420"
        let organizationCode: String = "SHYD"
        let imageURL: NSURL? = nil
        
        UserRequest.completeUserInfo(userId, gender: gender, height: height, age: age, name: name, phone: phone, organizationCode: organizationCode, imageURL: imageURL) { (error) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_UserRequest_CompleteInfo_isSuccess 错误: \(error!.description)")
        }
        
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
        
        
    }
    
    func test_UserRequest_createAndDeleteUser_isSucess() {
        let expectation = expectationWithDescription("test_UserRequest_createAndDeleteUser_isSucess")
        
        let name = "Other"
        let height = 142
        let age = 25
        let gender: Int = 1
        
        UserRequest.createUser(name, height: height, age: age, gender: gender) { (userId, error: NSError?) -> Void in
//            expectation.fulfill()
            XCTAssertNotNil(error, "test_UserRequest_createUser_isSucess 错误: \(error!.description)")
            
            UserRequest.deleteUser(userId!, complete: { (error: NSError?) -> Void in
                expectation.fulfill()
                XCTAssertNotNil(error, "test_UserRequest_deleteUser_isSucess 错误: \(error!.description)")
            })
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
    }
    
    func test_UserRequest_feedback_isSucess() {
        let expectation = expectationWithDescription("test_UserRequest_feedback_isSucess")
        
        UserRequest.feedBack(1234, feedback: "反馈测试") { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNotNil(error, "test_UserRequest_feedback_isSucess 错误: \(error!.description)")
        }
        
        waitForExpectationsWithTimeout(15, handler: { (error: NSError!) -> Void in
            XCTFail("请求超时")
        })
        
    }
}
