//
//  InputViewController.swift
//  APNsFlutter
//
//  Created by Arror on 2019/3/24.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

enum InputResult {
    case value(String)
    case cancel
}

class InputViewController: NSViewController {
    
    private var ensureAction: (InputResult) -> Void = { _ in }
    private var initialText: Optional<String> = .none

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.stringValue = self.title ?? ""
        self.valueTextField.stringValue = self.initialText ?? ""
    }
    
    @IBAction func ensureButtonTapped(_ sender: NSButton) {
        self.dismiss(self)
        self.ensureAction(InputResult.value(self.valueTextField.stringValue))
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.dismiss(self)
        self.ensureAction(InputResult.cancel)
    }
    
    static func makeViewController(title: String, initialText: Optional<String> = .none, compeltion: @escaping (InputResult) -> Void) -> InputViewController {
        let vc = NSStoryboard(name: NSStoryboard.Name("Input"), bundle: nil).instantiateInitialController() as! InputViewController
        vc.title = title
        vc.initialText = initialText
        vc.ensureAction = compeltion
        return vc
    }
}
