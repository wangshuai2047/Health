//
//  HealthTests.swift
//  HealthTests
//
//  Created by Yalin on 15/8/14.
//  Copyright (c) 2015年 Yalin. All rights reserved.
//

import UIKit
import XCTest

class HealthTests: XCTestCase {
    
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
    
    func test_timezone() {
        var timeZone = NSTimeZone.systemTimeZone()
        
        println("\(timeZone.secondsFromGMT / 60 / 60)")
        
        GoalManager.querySevenDaysData()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
}
