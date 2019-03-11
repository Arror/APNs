//
//  P12TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P12TabItemView: CertificateTabItemView {
    
    private var cerData: Optional<Data> = .none
    private var cerName: String = ""
    private var passphrase: String = ""
    
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
                case .some(let pair):
                    self.cerData = pair.1
                    self.cerName = pair.0.lastPathComponent
                    self.updateViews()
                case .none:
                    break
                }
            }
        }
        self.passphraseLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Passphrase", initialValue: self.passphraseLabel.stringValue) { result in
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
        self.certLabel.stringValue = self.cerName
        self.passphraseLabel.stringValue = self.passphrase
    }
    
    public override var certificate: Optional<APNs.Certificate> {
        return self.cerData.flatMap { .p12(name: self.cerName, data: $0, passphrase: self.passphrase) }
    }
}
