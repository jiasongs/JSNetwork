//
//  JSNetworkExampleTests.swift
//  JSNetworkExampleTests
//
//  Created by jiasong on 2021/9/8.
//  Copyright © 2021 jiasong. All rights reserved.
//

import XCTest
import JSNetwork

class JSNetworkExampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let parameters = "https://www.baidu.com?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlParameters()
        XCTAssert(parameters["zzzzz"] == "%E8%BF%98%E8%A1%8C", "")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
