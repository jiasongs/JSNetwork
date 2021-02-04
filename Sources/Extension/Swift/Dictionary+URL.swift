//
//  Dictionary+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == Dictionary<String, Any> {
    
    func urlParameterString() -> String {
        return self.nsDictionary.js_URLParameterString()
    }
    
}

fileprivate extension NetworkWrapper where Base == Dictionary<String, Any> {
    
    var nsDictionary: NSDictionary {
        return self.base as NSDictionary
    }
    
}
