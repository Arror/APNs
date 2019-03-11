//
//  P8TabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class P8TabItemView: CertificateTabItemView {
    
    private struct Info: Codable {
        
        var cerData: Optional<Data> = .none
        var cerName: String = ""
        var teamID: String = ""
        var keyID: String = ""
        var topic: String = ""
        
        init() {}
    }
    
    private var info = Info()
    
    @IBOutlet weak var certLabel: TappedLabel!
    @IBOutlet weak var teamLabel: TappedLabel!
    @IBOutlet weak var keyLabel: TappedLabel!
    @IBOutlet weak var topicLabel: TappedLabel!
    
    private let storageKey = "p8.info"
    
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
            NSOpenPanel.chooseCertificateFile(type: "p8", from: window) { result in
                switch result {
                case .some(let pair):
                    self.info.cerData = pair.1
                    self.info.cerName = pair.0.lastPathComponent
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
                    self.info.teamID = value
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
                    self.info.keyID = value
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
                    self.info.topic = value
                    self.updateViews()
                case .none:
                    break
                }
            }
            self.window?.windowController?.contentViewController?.presentAsSheet(vc)
        }
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.info.cerName
        self.teamLabel.stringValue = self.info.teamID
        self.keyLabel.stringValue = self.info.keyID
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
            !self.info.teamID.isEmpty, !self.info.keyID.isEmpty, !self.info.topic.isEmpty else {
                return .none
        }
        return self.info.cerData.flatMap { .p8(data: $0, teamID: self.info.teamID, keyID: self.info.keyID, topic: self.info.topic) }
    }
}
