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
        let destination = StringDestination(name: "com.APNs.StringDestination")
        destination.logUpdate = { d in
            self.logTextView.string = d.log
            self.logTextView.scrollRangeToVisible(NSRange(location: d.log.utf16.count, length: 0))
        }
        AppService.current.logger.add(destination: destination)
    }
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        do {
            let tokenPair = self.tokenTab.tokenPair
            guard
                !tokenPair.1.isEmpty else {
                    throw NSError.makeMessageError(message: "No Token")
            }
            guard
                let payload = self.jsonTextView.string.data(using: .utf8) else {
                    throw NSError.makeMessageError(message: "Payload error")
            }
            guard
                let cert = self.certTab.certificate else {
                    throw NSError.makeMessageError(message: "Certificate info error")
            }
            try AppEnvironment.current.updateProvider(withCertificate: cert)
            guard
                let provider = AppEnvironment.current.provider else {
                    throw NSError.makeMessageError(message: "Provider error")
            }
            let server = tokenPair.0
            tokenPair.1.forEach { token in
                let str: String = {
                    switch server {
                    case .sandbox:
                        return "Sandbox"
                    case .production:
                        return "Productuon"
                    }
                }()
                AppService.current.logger.log(level: .debug, message: "Send Notification, Server: \(str), Token: \(token)")
                provider.send(server: server, options: .default, token: token, payload: payload) { resp in
                    switch resp {
                    case .success:
                        AppService.current.logger.log(level: .debug, message: "Send Notification success")
                    case .failure(let error):
                        AppService.current.logger.log(level: .error, message: error.localizedDescription)
                    }
                }
            }
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
    }
}
