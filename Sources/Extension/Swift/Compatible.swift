//
//  JSNetworkCompatible.swift
//  JSNetwork
//
//  Created by jiasong on 2021/1/17.
//

import Foundation

public struct NetworkWrapper<Base> {
    
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
    
}

public protocol NetworkCompatible {}

extension NetworkCompatible {
    
    public static var jn: NetworkWrapper<Self>.Type {
        get { NetworkWrapper<Self>.self }
        set { }
    }
    
    public var jn: NetworkWrapper<Self> {
        get { NetworkWrapper(self) }
        set { }
    }
    
}

extension String: NetworkCompatible { }
extension Dictionary: NetworkCompatible { }
