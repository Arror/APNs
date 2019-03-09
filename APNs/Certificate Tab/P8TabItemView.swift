//
//  P8TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P8TabItemView: CertificateTabItemView {
    
    private var certURL: Optional<URL> = .none
    private var teamID: Optional<String> = .none
    private var keyID: Optional<String> = .none
    private var topicID: Optional<String> = .none
    
    @IBOutlet weak var certLabel: TappedLabel!
    @IBOutlet weak var teamLabel: TappedLabel!
    @IBOutlet weak var keyLabel: TappedLabel!
    @IBOutlet weak var topicLabel: TappedLabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.certLabel.tapped = { _ in
            guard
                let window = self.window else {
                    return
            }
            NSOpenPanel.chooseCertificateFile(type: "p8", from: window) { result in
                switch result {
                case .some(let value):
                    self.certURL = value
                    self.updateViews()
                case .none:
                    break
                }
            }
        }
        self.teamLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Team ID", initialValue: self.teamLabel.stringValue) { result in
                switch result {
                case .some(let value):
                    self.teamID = value
                    self.updateViews()
                case .none:
                    break
                }
            }
            self.window?.windowController?.contentViewController?.presentAsSheet(vc)
        }
        self.keyLabel.tapped = { _ in
            let vc = InputSheetViewController.makeViewController(title: "Key ID", initialValue: self.keyLabel.stringValue) { result in
                switch result {
                case .some(let value):
                    self.keyID = value
                    self.updateViews()
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
                    self.topicID = value
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
        self.teamLabel.stringValue = self.teamID ?? ""
        self.keyLabel.stringValue = self.keyID ?? ""
        self.topicLabel.stringValue = self.topicID ?? ""
    }
    
    public override func makeProvider() -> Optional<APNs.Provider> {
        guard
            let url = self.certURL,
            let teamIDString = self.teamID, !teamIDString.isEmpty,
            let keyIDString = self.keyID, !keyIDString.isEmpty,
            let topicString = self.topicID, !topicString.isEmpty else {
                return .none
        }
        do {
            return try APNs.makeProvider(certificate: .p8(filePath: url.absoluteString, teamID: teamIDString, keyID: keyIDString))
        } catch {
            return .none
        }
    }
}
