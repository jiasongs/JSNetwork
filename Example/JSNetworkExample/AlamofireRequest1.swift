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
    
    private var task: URLSessionTask!
    
    open override func buildTask(withConfig config: JSNetworkRequestConfigProtocol,
                                 multipartFormData multipartFormDataBlock: @escaping (Any) -> Void,
                                 uploadProgress uploadProgressBlock: @escaping (Progress) -> Void,
                                 downloadProgress downloadProgressBlock: @escaping (Progress) -> Void,
                                 didCreateURLRequest didCreateURLRequestBlock: @escaping (URLRequest) -> Void,
                                 didCreateTask didCreateTaskBlock: @escaping (URLSessionTask) -> Void,
                                 didCompleted didCompletedBlock: @escaping (Any?, Error?) -> Void) {
        guard let url: URL = URL(string: config.requestUrl()) else {
            let error: NSError = NSError(domain: "com.alamofire.error", code: 404, userInfo: nil)
            return didCompletedBlock(nil, error)
        }
        var method: HTTPMethod = .get
        switch config.requestMethod?() {
        case .GET:
            method = .get
            break
        case .POST:
            method = .post
            break
        default:
            break
        }
        let requestBody: Dictionary<String, Any>? = config.requestBody?() as? Dictionary
        let responseSerializer = self.buildResponseSerializer(with: config)
        let monitor = ClosureEventMonitor()
        monitor.requestDidCreateURLRequest = { (requst: Request, urlRequest: URLRequest) in
            didCreateURLRequestBlock(urlRequest)
        }
        monitor.requestDidCreateTask = { [weak self](requst: Request, task: URLSessionTask) in
            didCreateTaskBlock(task)
            self?.task = task
        }
        let session = Session(eventMonitors: [monitor])
        session.request(url).responseJSON { (r) in
            
        }
    }
    
    open override func requestTask() -> URLSessionTask {
        return self.task
    }
    
    override open func cancel() -> Void {
        
    }
    
    deinit {
        
    }
    
}

extension AlamofireRequest1 {
    
    func buildResponseSerializer(with config: JSNetworkRequestConfigProtocol) -> Any {
        let type: JSResponseSerializerType = config.responseSerializerType?() ?? .JSON
        if type == .HTTP {
            return StringResponseSerializer()
        }
        return JSONResponseSerializer()
    }
    
}
