//
//  Dictionary+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == Dictionary<String, Any> {
    
    static func urlQueryDictionary(with urlString: String) -> Dictionary<String, Any> {
        let dictionary = NSDictionary.js_urlQueryDictionary(URLString: urlString)
        return dictionary
    }
    
    func urlQueryString() -> String {
        let nsDictionary: NSDictionary = NSDictionary(dictionary: self.base)
        return nsDictionary.js_URLQueryString()
    }
    
}
