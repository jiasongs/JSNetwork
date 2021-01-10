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
                                 didCreateURLRequest didCreateURLRequestBlock: @escaping (NSMutableURLRequest) -> Void,
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
        
//        AF.request(url, method: method, parameters: nil, encoding: URLEncodedFormParameterEncoder.default as! ParameterEncoding, headers: nil, interceptor: nil, requestModifier: nil).response(queue: JSNetworkConfig.shared().completionQueue, responseSerializer: self.buildResponseSerializer<StringResponseSerializer>(with: config)) { (response: AFDataResponse) in
//
//        }
        //        AF.request(url).response(queue: JSNetworkConfig.shared().completionQueue, responseSerializer: self.buildResponseSerializer(with: config)) { (response: AFDataResponse<JSONResponseSerializer>) in
        //
        //        }
        
        //        AF.request("https://httpbin.org/get")
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
    
    func buildResponseSerializer<Serializer: ResponseSerializer>(with config: JSNetworkRequestConfigProtocol) -> Serializer {
        switch config.responseSerializerType?() {
        case .HTTP:
            return StringResponseSerializer() as! Serializer
        case .xmlParser:
            break
        default:
            return JSONResponseSerializer() as! Serializer
        }
        return JSONResponseSerializer() as! Serializer
    }
    
}
