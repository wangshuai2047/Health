//
//  RequestTests.swift
//  Health
//
//  Created by Yalin on 15/9/8.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class RequestTests: XCTestCase {

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

    func test_Request_generatePHPStyleBodyStr_isSuccess() {
        let params = ["phone" : "18611111111", "captachas" : "SDFHI"]
        print(Request.generatePHPStyleBodyStr("100002", params: params))
    }
}
