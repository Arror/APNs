//
//  TeamIDView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

class TeamIDView: NSView {
    
    @IBOutlet private weak var textField: APNsTextField!
            
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.stringValue = AppService.current.teamIDObject.value
        self.textField.onTextChanged = { AppService.current.teamIDObject.value = $0 }
    }
}
