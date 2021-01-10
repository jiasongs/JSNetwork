//
//  AlamofireRequest.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/9.
//

import UIKit
import Alamofire

@objc open class AlamofireRequest: JSNetworkRequest {
    
    private var task: URLSessionTask!
    
    
    open override func requestTask() -> URLSessionTask {
        return self.task
    }
    
    override open func cancel() -> Void {
        
    }
    
    deinit {
        
    }
    
}
