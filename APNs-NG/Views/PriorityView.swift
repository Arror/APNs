//
//  PriorityView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/28.
//  Copyright © 2020 Arror. All rights reserved.
//

import Cocoa

class PriorityView: NSView {
    
    @IBOutlet private weak var priorityPicker: NSPopUpButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.priorityPicker.removeAllItems()
        self.priorityPicker.addItems(withTitles: (1...10).map({ "\($0)" }))
        self.priorityPicker.select(self.priorityPicker.item(at: AppService.current.priorityObject.value - 1))
        self.priorityPicker.target = self
        self.priorityPicker.action = #selector(priorityPickerValueChange(_:))
    }
    
    @objc private func priorityPickerValueChange(_ sender: NSPopUpButton) {
        AppService.current.priorityObject.value = sender.indexOfSelectedItem + 1
    }
}
