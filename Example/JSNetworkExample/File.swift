//
//  File.swift
//  JSNetworkExample
//
//  Created by jiasong on 2020/12/18.
//  Copyright © 2020 jiasong. All rights reserved.
//

import UIKit
import JSNetwork

class SwfitViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var zz: Dictionary<String, Any> = ["key": 1]
        
        zz.jn.urlParameterString()
        
        let str = "123"
        let par: [String: String] = str.jn.urlParameters()
        
        (str as NSString).js_URLStringByAppending(parameters: zz)
    }
    
}
