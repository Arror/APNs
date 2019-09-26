//
//  P12TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P12TabItemView: CertificateTabItemView {
    
    private struct Info: Codable {
        
        var cerData: Optional<Data> = .none
        var cerName: String = ""
        var passphrase: String = ""
        var topic: String = ""
        
        init() {}
    }
    
    private var info = Info()
    
    private let storageKey = "p12.info"
    
    @IBOutlet weak var certLabel: TappedLabel!
    @IBOutlet weak var passphraseLabel: TappedLabel!
    @IBOutlet weak var topicLabel: TappedLabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        do {
            self.info = try AppUser.current.storage.item(for: self.storageKey) ?? Info()
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
        self.updateViews()
        self.certLabel.tapped = { _ in
            guard
                let window = self.window else {
                    return
            }
            NSOpenPanel.chooseCertificateFile(type: "p12", from: window) { result in
                switch result {
                case .some(let pair):
                    self.info.cerData = pair.1
                    self.info.cerName = pair.0.lastPathComponent
                    self.updateViews()
                    self.updateStorage()
                case .none:
                    break
                }
            }
        }
        self.passphraseLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Passphrase", initialValue: self.passphraseLabel.stringValue) { result in
                switch result {
                case .some(let value):
                    self.info.passphrase = value
                    self.updateViews()
                    self.updateStorage()
                case .none:
                    break
                }
            }
            self.window?.windowController?.contentViewController?.presentAsSheet(vc)
        }
        self.topicLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Bundle ID", initialValue: self.topicLabel.stringValue) { result in
                switch result {
                case .some(let value):
                    self.info.topic = value
                    self.updateViews()
                    self.updateStorage()
                case .none:
                    break
                }
            }
            self.window?.windowController?.contentViewController?.presentAsSheet(vc)
        }
    }
    
    @IBAction func clearCertificateButtonTapped(_ sender: NSButton) {
        self.info.cerData = .none
        self.info.cerName = ""
        self.updateViews()
        self.updateStorage()
    }
    
    @IBAction func clearPassphraseButtonTapped(_ sender: NSButton) {
        self.info.passphrase = ""
        self.updateViews()
        self.updateStorage()
    }
    
    @IBAction func clearTopicButtonTapped(_ sender: NSButton) {
        self.info.topic = ""
        self.updateViews()
        self.updateStorage()
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.info.cerName
        self.passphraseLabel.stringValue = self.info.passphrase
        self.topicLabel.stringValue = self.info.topic
    }
    
    private func updateStorage() {
        do {
            try AppUser.current.storage.set(item: self.info, for: self.storageKey)
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
    }
    
    public override var certificate: Optional<APNs.Certificate> {
        guard
            let data = self.info.cerData, !self.info.topic.isEmpty else {
                return .none
        }
        return .p12(data: data, passphrase: self.info.passphrase, topic: self.info.topic)
    }
}
