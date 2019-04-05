//
//  InputViewController.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class InputViewController: NSViewController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    
    private var value: String = ""
    private var completion: (InputViewController, Optional<String>) -> Void = { _, _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.stringValue = self.title ?? ""
        self.valueTextField.stringValue = self.value
    }
    
    @IBAction func confirmButtonTapped(_ sender: NSButton) {
        self.completion(self, self.valueTextField.stringValue)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.completion(self, .none)
    }
    
    static func makeViewController(title: String, value: String, completion: @escaping (InputViewController, Optional<String>) -> Void) -> InputViewController {
        let vc = NSStoryboard(name: "APNsPlugin", bundle: nil).instantiateController(withIdentifier: "InputViewController") as! InputViewController
        vc.title = title
        vc.value = value
        vc.completion = completion
        return vc
    }
}
