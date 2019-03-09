//
//  TappedLabel.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class TappedLabel: NSTextField {
    
    var tapped: (TappedLabel) -> Void = { _ in }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(_tapped(_:))))
    }
    
    @objc private func _tapped(_ sender: NSClickGestureRecognizer) {
        self.tapped(self)
    }
}
