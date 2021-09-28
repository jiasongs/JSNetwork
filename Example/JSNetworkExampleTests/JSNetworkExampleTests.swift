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
        
        let parameters = "https://www.baidu.com/path1/path2#mao?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlParameters()
        XCTAssert(parameters["zzzzz"] == "%E8%BF%98%E8%A1%8C", "\(parameters)")
        XCTAssert(parameters["dfffff"] == "你好吗", "\(parameters)")
        
        var url = "https://www.baidu.com?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com")
        
        url = "https://www.baidu.com/path1/path2#mao?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com/path1/path2#mao", "\(url)")
        
        url = "https://www.baidu.com/中文/path2#mao?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com/中文/path2#mao", "\(url)")
        
        url = "https://www.baidu.com/%E8%BF%98%E8%A1%8C/path2#mao?zz=123&dfffff=你好吗&zzzzz=%E8%BF%98%E8%A1%8C".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com/%E8%BF%98%E8%A1%8C/path2#mao", "\(url)")
        
        url = "https://www.baidu.com".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com", "\(url)")
        
        url = "https://www.baidu.com/path1/path2#mao".jn.urlByDeletingParameter()
        XCTAssert(url == "https://www.baidu.com/path1/path2#mao", "\(url)")
        
        url = "ithome://host".jn.urlByDeletingParameter()
        XCTAssert(url == "ithome://host", "\(url)")
        
        url = "ithome://hostlist".jn.urlByDeletingParameter()
        XCTAssert(url == "ithome://hostlist", "\(url)")
        
        url = "hostlist?zz=123&dfffff=你好吗".jn.urlByDeletingParameter()
        XCTAssert(url == "hostlist", "\(url)")
        
        url = "https://zz.api.com/m/nn?userhash=888888".jn.urlStringByAppending(parameters: ["userhash": "77777"])
        XCTAssert(url == "https://zz.api.com/m/nn?userhash=77777", "\(url)")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
