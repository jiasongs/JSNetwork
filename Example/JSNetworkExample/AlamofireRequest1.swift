//
//  AlamofireRequest.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/9.
//

import UIKit
import Alamofire
import JSNetwork

@objc open class AlamofireRequest1: JSNetworkRequest {
    
    private var dataRequest: DataRequest!
    private var task: URLSessionTask!
    
    open override func buildTask(withConfig config: JSNetworkRequestConfigProtocol,
                                 multipartFormData multipartFormDataBlock: @escaping (Any) -> Void,
                                 uploadProgress uploadProgressBlock: @escaping (Progress) -> Void,
                                 downloadProgress downloadProgressBlock: @escaping (Progress) -> Void,
                                 didCreateURLRequest didCreateURLRequestBlock: @escaping (NSMutableURLRequest) -> Void,
                                 didCreateTask didCreateTaskBlock: @escaping (URLSessionTask) -> Void,
                                 didCompleted didCompletedBlock: @escaping (Any?, Error?) -> Void) {
        guard let url: URL = URL(string: config.requestUrlString()) else {
            let error: NSError = NSError(domain: "com.alamofire.error", code: 404, userInfo: nil)
            return didCompletedBlock(nil, error)
        }
        var method: HTTPMethod = .get
        switch config.requestMethod?() {
        case .get:
            method = .get
            break
        case .post:
            method = .post
            break
        default:
            break
        }
        let requestBody: Dictionary<String, Any>? = config.requestBody?() as? Dictionary
        let responseSerializer = self.buildResponseSerializer(with: config)
        let monitor = ClosureEventMonitor()
        monitor.requestDidCreateURLRequest = { (requst: Request, urlRequest: URLRequest) in
            let mutableURLRequest = urlRequest as? NSMutableURLRequest ?? NSMutableURLRequest(url: url)
            didCreateURLRequestBlock(mutableURLRequest)
        }
        monitor.requestDidCreateTask = { [weak self](requst: Request, task: URLSessionTask) in
            self?.task = task
            didCreateTaskBlock(task)
        }
        let session = Session(startRequestsImmediately: false, eventMonitors: [monitor])
        self.dataRequest = session.request(url)
    }
    
    open override func requestTask() -> URLSessionTask {
        return self.task
    }
    
    override open func start() -> Void {
        self.dataRequest.resume()
    }
    
    override open func cancel() -> Void {
        self.dataRequest.cancel()
    }
    
    deinit {
        
    }
    
}

extension AlamofireRequest1 {
    
    func buildResponseSerializer(with config: JSNetworkRequestConfigProtocol) -> Any {
        let type: JSResponseSerializerType = config.responseSerializerType?() ?? .json
        if type == .http {
            return StringResponseSerializer()
        }
        return JSONResponseSerializer()
    }
    
}
