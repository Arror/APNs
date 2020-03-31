//
//  TeamIDView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa
import Combine

class TeamIDView: NSView {
    
    @IBOutlet private weak var textField: APNsTextField!
    
    private var cancellables: Set<AnyCancellable> = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.stringValue = AppService.current.teamIDObject.value
        self.textField.onTextChanged = { AppService.current.teamIDObject.value = $0 }
        self.cancellables.insert(
            AppService.current.teamIDObject.$value.assign(to: \TeamIDView.textField.stringValue, on: self)
        )
    }
}
