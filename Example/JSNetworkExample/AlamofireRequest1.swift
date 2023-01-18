//
//  AlamofireRequest.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/9.
//

import UIKit
import Alamofire
import JSNetwork

@objc public class AlamofireRequest1: JSNetworkRequest {
    
    fileprivate var dataRequest: DataRequest?
    fileprivate var task: URLSessionTask?
    
    public override func buildTask(withConfig config: JSNetworkRequestConfigProtocol,
                                 uploadProgress: @escaping (Progress) -> Void,
                                 downloadProgress: @escaping (Progress) -> Void,
                                 constructingFormData: @escaping (Any) -> Void,
                                 didCreateURLRequest: @escaping (URLRequest) -> URLRequest,
                                 didCreateTask: @escaping (URLSessionTask) -> Void,
                                 didCompleted: @escaping (Any?, Error?) -> Void) {
        guard let url: URL = URL(string: config.requestUrlString()) else {
            let userInfo = [NSLocalizedDescriptionKey: "url不存在"]
            let error = NSError(domain: "com.alamofire.error", code: 404, userInfo: userInfo)
            return didCompleted(nil, error)
        }
        var method: HTTPMethod = .get
        switch config.requestMethod?() {
        case .get:
            method = .get
            break
        case .post:
            method = .post
            break
        case .head:
            method = .head
            break
        case .put:
            method = .put
            break
        case .delete:
            method = .delete
            break
        case .patch:
            method = .patch
            break
        default:
            break
        }
        let requestBody = config.requestBody?()
       
        
        let redirector = Redirector(behavior: .modify({ (task, request, response) -> URLRequest in
            return didCreateURLRequest(request)
        }))
        let monitor = ClosureEventMonitor()
        monitor.requestDidCreateTask = { [weak self](requst: Request, task: URLSessionTask) in
            didCreateTask(task)
        }
        let session = Session(startRequestsImmediately: false, redirectHandler: redirector, eventMonitors: [monitor])
        self.dataRequest = session.request(url,
                                           method: method,
                                           parameters: nil,
                                           headers: nil,
                                           interceptor: nil,
                                           requestModifier: nil)
        switch config.responseSerializerType?() {
        case .http:
            self.dataRequest?.responseString(completionHandler: { response in
                
            })
            break
        case .json:
//            self.dataRequest?.responseDecodable(emptyRequestMethods: <#T##Set<HTTPMethod>#>, completionHandler: <#T##(DataResponse<Decodable, AFError>) -> Void#>)
            break
        case .xmlParser:
            break
        default:
            break
        }
    }
    
    open override func requestTask() -> URLSessionTask {
        guard let task = self.task else {
            fatalError("不能为nil")
        }
        return task
    }
    
    override open func start() -> Void {
        self.dataRequest?.resume()
    }
    
    override open func cancel() -> Void {
        self.dataRequest?.cancel()
    }
    
}
