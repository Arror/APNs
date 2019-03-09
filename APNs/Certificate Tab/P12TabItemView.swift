//
//  P12TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P12TabItemView: CertificateTabItemView {
    
    private var certURL: Optional<URL> = .none
    private var passphrase: Optional<String> = .none
    
    @IBOutlet weak var certLabel: TappedLabel!
    @IBOutlet weak var passphraseLabel: TappedLabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.certLabel.tapped = { _ in
            guard
                let window = self.window else {
                    return
            }
            NSOpenPanel.chooseCertificateFile(type: "p12", from: window) { result in
                switch result {
                case .some(let value):
                    self.certURL = value
                    self.updateViews()
                case .none:
                    break
                }
            }
        }
        self.passphraseLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Team ID", initialValue: self.passphraseLabel.stringValue) { result in
                switch result {
                case .some(let value):
                    self.passphrase = value
                    self.updateViews()
                case .none:
                    break
                }
            }
            self.window?.windowController?.contentViewController?.presentAsSheet(vc)
        }
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.certURL.flatMap { $0.lastPathComponent } ?? ""
        self.passphraseLabel.stringValue = self.passphrase ?? ""
    }
    
    public override func makeProvider() -> Optional<APNs.Provider> {
        guard
            let url = self.certURL, let passphrase = self.passphrase else {
                return .none
        }
        do {
            return try APNs.makeProvider(certificate: .p12(filePath: url.absoluteString, passphrase: passphrase))
        } catch {
            return .none
        }
    }
}
