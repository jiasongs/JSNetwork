//
//  String+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public extension NetworkWrapper where Base == String {
    
    func urlLastPath() -> String? {
        let nsString = NSString(string: self.base)
        return nsString.js_URLLastPath()
    }

    func urlByDeletingLastPath() -> String {
        let nsString = NSString(string: self.base)
        return nsString.js_URLByDeletingLastPath()
    }

    func urlPaths() -> Array<String> {
        let nsString = NSString(string: self.base)
        return nsString.js_URLPaths()
    }

    func urlStringByAppending(paths: Array<String> = [], parameters: Dictionary<String, Any> = [:]) -> String {
        let nsString = NSString(string: self.base)
        return nsString.js_URLStringByAppending(paths: paths, parameters: parameters)
    }
    
    func urlStringEncode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        let nsString = NSString(string: self.base)
        return nsString.js_URLStringEncode(usingEncoding: encoding.rawValue)
    }
    
    func urlStringDecode(usingEncoding encoding: String.Encoding = .utf8) -> String {
        let nsString = NSString(string: self.base)
        return nsString.js_URLStringDecode(usingEncoding: encoding.rawValue)
    }
    
}
