//
//  KeyIDView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

class KeyIDView: NSView {
    
    @IBOutlet private weak var textField: APNsTextField!
    
    private var cancellables: Set<AnyCancellable> = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.stringValue = AppService.current.keyIDObject.value
        self.textField.onTextChanged = { AppService.current.keyIDObject.value = $0 }
        self.cancellables.insert(
            AppService.current.keyIDObject.$value.assign(to: \KeyIDView.textField.stringValue, on: self)
        )
    }
}
