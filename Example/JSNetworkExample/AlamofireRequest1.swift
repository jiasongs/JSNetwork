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
    
    public override func buildTask(withConfig config: JSNetworkRequestConfigProtocol,
                                   multipartFormData multipartFormDataBlock: @escaping (Any) -> Void,
                                   didCreateURLRequest didCreateURLRequestBlock: @escaping (NSMutableURLRequest) -> Void,
                                   didCreateTask didCreateTaskBlock: @escaping (URLSessionTask) -> Void,
                                   uploadProgress uploadProgressBlock: @escaping (Progress) -> Void,
                                   downloadProgress downloadProgressBlock: @escaping (Progress) -> Void,
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
        
//        var responseSerializer
//        switch config.responseSerializerType?() {
//        case .HTTP:
//            responseSerializer = StringResponseSerializer()
//            break
//        case .xmlParser:
//            break
//        default:
//            responseSerializer = JSONResponseSerializer()
//            break
//        }
//        AF.request(url).response<Serializer: ResponseSerializer>(queue: JSNetworkConfig.shared().completionQueue, responseSerializer: JSONResponseSerializer()) { (AFDataResponse<ResponseSerializer>) in
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
