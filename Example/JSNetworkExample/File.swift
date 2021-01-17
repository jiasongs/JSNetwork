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
        var zz: Dictionary<String, Any> = ["key": "value"]
        
        zz.jn.urlQueryString()
    }
    
}
