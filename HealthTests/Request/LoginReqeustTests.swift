//
//  LoginReqeustTests.swift
//  Health
//
//  Created by Yalin on 15/8/20.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class LoginReqeustTests: XCTestCase {

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
    
    func test_loginRequest_queryCaptchas_isSucess() {
        
        let expectation = expectationWithDescription("test_loginRequest_queryCaptchas_isSucess")
        
        let phone = "18610729420"
        
        LoginRequest.queryCaptchas(phone, complete: { (authCode: String?, error: NSError?) -> Void in
            expectation.fulfill()
            XCTAssertNil(error, "获取验证码错误: \(error?.description)")
        })
        
        waitForExpectationsWithTimeout(15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_loginRequest_login_isSuccess() {
        let expectation = expectationWithDescription("test_loginRequest_login_isSuccess")
        
        let phone = "18610729420"
        let captchas = "872728"
        LoginRequest.login(phone, captchas: captchas) { (userInfo, error: NSError?) -> Void in
            expectation.fulfill()
            
            XCTAssertNil(error, "登录错误: \(error?.description)")
        }
        
        waitForExpectationsWithTimeout(15) { (error: NSError?) -> Void in
            
        }
    }
    
    func test_loginRequest_loginThirdPlatform_isSucess() {
        let expectation = expectationWithDescription("test_loginRequest_loginThirdPlatform_isSucess")
        
        LoginRequest.loginThirdPlatform("亚霖", headURLStr: "http://www.baidu.com", openId: "13423456", type: ThirdPlatformType.QQ) { (userInfo, error: NSError?) -> Void in
            expectation.fulfill()
            
             XCTAssertNil(error, "登录第三方平台错误: \(error?.description)")
        }
        
        waitForExpectationsWithTimeout(15) { (error: NSError?) -> Void in
            
        }
    }
    
    
}
