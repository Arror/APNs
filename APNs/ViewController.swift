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
                    throw NSError.makeMessageError(message: "无设备Token")
            }
            guard
                let payload = self.jsonTextView.string.data(using: .utf8) else {
                    throw NSError.makeMessageError(message: "负载格式错误")
            }
            guard
                let cert = self.certTab.certificate else {
                    throw NSError.makeMessageError(message: "无法创建推送服务")
            }
            try AppUser.current.updateProvider(withCertificate: cert)
            guard
                let provider = AppUser.current.provider else {
                    throw NSError.makeMessageError(message: "无法创建推送服务")
            }
            let server = tokenPair.0
            tokenPair.1.forEach { token in
                let str: String = {
                    switch server {
                    case .sandbox:
                        return "测试"
                    case .production:
                        return "生产"
                    }
                }()
                AppService.current.logger.log(level: .debug, message: "发送通知, 环境: \(str), Token: \(token)")
                provider.send(server: server, options: .default, token: token, payload: payload) { resp in
                    switch resp {
                    case .success:
                        AppService.current.logger.log(level: .debug, message: "发送通知成功")
                    case .failure(let error):
                        AppService.current.logger.log(level: .error, message: "推送失败，原因：\(error.localizedDescription)")
                    }
                }
            }
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
    }
}
