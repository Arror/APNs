//
//  APNsTextField.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

class APNsTextField: NSTextField {
    
    var onTextChanged: (String) -> Void = { _ in }
    
    override func textDidChange(_ notification: Notification) {
        self.onTextChanged(self.stringValue)
    }
}
