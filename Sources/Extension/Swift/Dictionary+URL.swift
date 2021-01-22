//
//  Dictionary+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == Dictionary<String, Any> {
    
    static func urlQueryDictionary(with urlString: String) -> Dictionary<String, Any> {
        return NSDictionary.js_urlQueryDictionary(URLString: urlString)
    }
    
    func urlQueryString() -> String {
        return self.nsDictionary.js_URLQueryString()
    }
    
}

fileprivate extension NetworkWrapper where Base == Dictionary<String, Any> {
    
    var nsDictionary: NSDictionary {
        return self.base as NSDictionary
    }
    
}
