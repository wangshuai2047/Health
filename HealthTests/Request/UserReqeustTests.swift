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
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

    func test_UserRequest_CompleteInfo_isSuccess() {
        
        let expectation = self.expectation(withDescription: "test_UserRequest_CompleteInfo_isSuccess")
        
        let userId: Int = 10
        let gender: Bool = true
        let height: UInt8 = 168
        let age: UInt8 = 25
        let name: String = "Mfewfjweie"
        let phone: String = "18610729420"
        let organizationCode: String = "SHYD"
        let imagePath = Bundle.main.path(forResource: "11111", ofType: "png")
        let imageURL: String? = imagePath
        
        UserRequest.completeUserInfo(userId, gender: gender, height: height, age: age, name: name, phone: phone, organizationCode: organizationCode, imageURL: imageURL) { (headURL, error) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_UserRequest_CompleteInfo_isSuccess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
        
        
    }
    
    func test_UserRequest_createAndDeleteUser_isSucess() {
        let expectation = self.expectation(withDescription: "test_UserRequest_createAndDeleteUser_isSucess")
        
        let pid = 10
        let name = "Other"
        let height = 142
        let age = 25
        let gender: Bool = false
        
        UserRequest.createUser(pid, name: name, height: height, age: age, gender: gender, imageURL:nil) { (userId, headURL, error: NSError?) -> Void in
            XCTAssertNil(error, "test_UserRequest_createUser_isSucess 错误: \(error?.description)")
            
            UserRequest.deleteUser(pid, userId: userId!, complete: { (error: NSError?) -> Void in
                expectation.fulfill()
                XCTAssertNil(error, "test_UserRequest_deleteUser_isSucess 错误: \(error?.description)")
            })
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_UserRequest_feedback_isSucess() {
        let expectation = self.expectation(withDescription: "test_UserRequest_feedback_isSucess")
        
        UserRequest.feedBack(10, feedback: "反馈测试") { (error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "test_UserRequest_feedback_isSucess 错误: \(error?.description)")
        }
        
        waitForExpectations(withTimeout: 15) { (error: NSError?) -> Void in
            
        }
        
    }
}
