//
//  PayloadViewController.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/16.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

class PayloadViewController: NSViewController {
    
    @IBOutlet private(set) var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PayloadViewController {
    
    static func makeViewController() -> PayloadViewController {
        return NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "PayloadViewController")
    }
}
