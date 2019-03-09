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
        self.jsonTextView.string = """
        {
            "aps": {
                "alert": "Your message Here"
            }
        }
        """
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        do {
            let tokenInfo = self.tokenListView.tokenInfo
            guard
                !tokenInfo.0.isEmpty else {
                    throw APNs.makeError(message: "No Token")
            }
            guard
                let payload = self.jsonTextView.string.data(using: .utf8) else {
                    throw APNs.makeError(message: "")
            }
            guard
                let cert = self.certTab.certificate else {
                    throw APNs.makeError(message: "")
            }
            try AppEnvironment.current.updateProvider(withCertificate: cert)
            guard
                let provider = AppEnvironment.current.provider else {
                    throw APNs.makeError(message: "")
            }
            tokenInfo.0.forEach { token in
                provider.send(server: tokenInfo.1, options: .default, token: token, payload: payload) { resp in
                    
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension APNs {
    
    static func makeError(message: String) -> NSError {
        return NSError(domain: "APNs", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
