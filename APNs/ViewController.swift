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
    @IBOutlet weak var tokenTab: TokenTabView!
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
                "content-available": 1,
                "alert": {
                    "title": "Title",
                    "body": "Your message here."
                },
                "badge": 9,
                "sound": "default"
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
            let tokenPair = self.tokenTab.tokenPair
            guard
                !tokenPair.1.isEmpty else {
                    throw APNs.makeError(message: "Token empty")
            }
            guard
                let payload = self.jsonTextView.string.data(using: .utf8) else {
                    throw APNs.makeError(message: "Payload error")
            }
            guard
                let cert = self.certTab.certificate else {
                    throw APNs.makeError(message: "Certificate error")
            }
            try AppEnvironment.current.updateProvider(withCertificate: cert)
            guard
                let provider = AppEnvironment.current.provider else {
                    throw APNs.makeError(message: "Provider error")
            }
            let server = tokenPair.0
            tokenPair.1.forEach { token in
                provider.send(server: server, options: .default, token: token, payload: payload) { resp in
                    
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
