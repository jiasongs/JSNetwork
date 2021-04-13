//
//  Dictionary+URL.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public protocol DictionaryType {}
extension Dictionary: DictionaryType {}

public extension NetworkWrapper where Base : DictionaryType {
    
    func urlParameterString() -> String {
        return self.nsDictionary?.js_urlParameterString() ?? ""
    }
    
}

fileprivate extension NetworkWrapper where Base : DictionaryType {
    
    var nsDictionary: NSDictionary? {
        return self.base as? NSDictionary
    }
    
}
