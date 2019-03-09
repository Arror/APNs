//
//  InputSheetViewController.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class InputSheetViewController: NSViewController {
    
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var value: Optional<String>
    
    private var compeltion: (Optional<String>) -> Void = { _ in }
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.stringValue = self.title ?? ""
        self.valueTextField.stringValue = self.value ?? ""
    }
    
    @IBAction func doneButtonTapped(_ sender: NSButton) {
        let value = self.valueTextField.stringValue
        self.compeltion(value)
        self.dismiss(self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        self.compeltion(.none)
        self.dismiss(self)
    }
    
    static func makeViewController(title: String, initialValue: Optional<String> = .none, compeltion: @escaping (Optional<String>) -> Void) -> InputSheetViewController {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "InputSheetViewController") as! InputSheetViewController
        vc.title = title
        vc.value = initialValue ?? ""
        vc.compeltion = compeltion
        return vc
    }
}
