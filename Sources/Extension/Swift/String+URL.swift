//
//  String+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == String {
    
    func urlLastPath() -> String? {
        return self.nsString.js_URLLastPath()
    }
    
    func urlByDeletingLastPath() -> String {
        return self.nsString.js_URLByDeletingLastPath()
    }
    
    func urlPaths() -> Array<String> {
        return self.nsString.js_URLPaths()
    }
    
    func urlParameters() -> [String: String] {
        return self.nsString.js_URLParameters()
    }
    
    func urlStringByAppending(paths: Array<String> = [], parameters: Dictionary<String, Any> = [:]) -> String {
        return self.nsString.js_URLStringByAppending(paths: paths, parameters: parameters)
    }
    
    func urlStringEncode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        return self.nsString.js_URLStringEncode(usingEncoding: encoding.rawValue)
    }
    
    func urlStringDecode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        return self.nsString.js_URLStringDecode(usingEncoding: encoding.rawValue)
    }
    
}

fileprivate extension NetworkWrapper where Base == String {
    
    var nsString: NSString {
        return self.base as NSString
    }
    
}
