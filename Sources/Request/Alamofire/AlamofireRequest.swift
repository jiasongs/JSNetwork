//
//  AlamofireRequest.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/9.
//

import Foundation

@objc open class AlamofireRequest: JSNetworkRequest, @unchecked Sendable {
    
    private var task: URLSessionTask!
    
    
    open override func requestTask() -> URLSessionTask {
        return self.task
    }
    
    override open func cancel() -> Void {
        
    }
    
    deinit {
        
    }
    
}
