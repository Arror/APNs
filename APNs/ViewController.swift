//
//  ViewController.swift
//  APNs
//
//  Created by Arror on 2019/3/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var certTab: CertificateTabView!
    @IBOutlet weak var tokenListView: TokenListView!
    @IBOutlet var jsonTextView: NSTextView! {
        didSet {
            self.jsonTextView.isAutomaticQuoteSubstitutionEnabled = false
        }
    }
    @IBOutlet var logTextView: NSTextView! {
        didSet {
            self.logTextView.isAutomaticQuoteSubstitutionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        
    }
}
