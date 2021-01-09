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
    
    public override func buildTask(withConfig config: JSNetworkRequestConfigProtocol,
                                   multipartFormData multipartFormDataBlock: @escaping (Any) -> Void,
                                   didCreateURLRequest didCreateURLRequestBlock: @escaping (NSMutableURLRequest) -> Void,
                                   didCreateTask didCreateTaskBlock: @escaping (URLSessionTask) -> Void,
                                   uploadProgress uploadProgressBlock: @escaping (Progress) -> Void,
                                   downloadProgress downloadProgressBlock: @escaping (Progress) -> Void,
                                   didCompleted didCompletedBlock: @escaping (Any?, Error?) -> Void) {
        
    }
    
    open override func requestTask() -> URLSessionTask {
        return self.task
    }
    
    override open func cancel() -> Void {
        
    }
    
    deinit {
        
    }
    
}
