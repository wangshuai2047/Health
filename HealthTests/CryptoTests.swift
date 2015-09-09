//
//  CryptoTests.swift
//  Health
//
//  Created by Yalin on 15/9/8.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class CryptoTests: XCTestCase {

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

    func test_Crypto_md5_isSuccess() {
        let beforeMD5Str = "test_Crypto_md5_isSuccess"
        
        let laterMD5Str = beforeMD5Str.md5Value
        
        XCTAssert(laterMD5Str == "e231cdebe1ebc3bcdd9d88d573ee2e3f", "md5成功")
    }
}
