//
//  P8TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P8TabItemView: CertificateTabItemView {
    
    private var cerData: Optional<Data> = .none
    private var cerName: String = ""
    private var teamID: String = ""
    private var keyID: String = ""
    private var topic: String = ""
    
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
                case .some(let pair):
                    self.cerData = pair.1
                    self.cerName = pair.0.lastPathComponent
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
                    self.topic = value
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
        self.teamLabel.stringValue = self.teamID
        self.keyLabel.stringValue = self.keyID
        self.topicLabel.stringValue = self.topic
    }
    
    public override var certificate: Optional<APNs.Certificate> {
        guard
            !self.teamID.isEmpty, !self.keyID.isEmpty, !self.topic.isEmpty else {
                return .none
        }
        return self.cerData.flatMap { .p8(data: $0, teamID: self.teamID, keyID: self.keyID, topic: self.topic) }
    }
}
