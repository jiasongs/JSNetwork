//
//  String+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == String {
    
    func urlLastPath() -> String? {
        return self.nsString.js_urlLastPath()
    }
    
    func urlByDeletingLastPath() -> String {
        return self.nsString.js_urlByDeletingLastPath()
    }
    
    func urlPaths() -> Array<String> {
        return self.nsString.js_urlPaths()
    }
    
    func urlByDeletingLastParameter() -> String {
        return self.nsString.js_urlByDeletingParameter()
    }
    
    func urlParameters() -> [String: String] {
        return self.nsString.js_urlParameters()
    }
    
    func urlStringByAppending(paths: Array<String> = [], parameters: Dictionary<String, Any> = [:]) -> String {
        return self.nsString.js_urlStringByAppending(paths: paths, parameters: parameters)
    }
    
    func urlStringEncode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        return self.nsString.js_urlStringEncode(usingEncoding: encoding.rawValue)
    }
    
    func urlStringDecode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        return self.nsString.js_urlStringDecode(usingEncoding: encoding.rawValue)
    }
    
}

fileprivate extension NetworkWrapper where Base == String {
    
    var nsString: NSString {
        return self.base as NSString
    }
    
}
