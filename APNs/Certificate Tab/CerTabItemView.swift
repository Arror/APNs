//
//  CerTabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class CerTabItemView: CertificateTabItemView {
    
    private struct Info: Codable {
        
        var cerData: Optional<Data> = .none
        var cerName: String = ""
        
        init() {}
    }
    
    private var info = Info()
    
    private let storageKey = "p12.info"
    
    @IBOutlet weak var certLabel: TappedLabel!
    
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
            NSOpenPanel.chooseCertificateFile(type: "cer", from: window) { result in
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
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.info.cerName
    }
    
    private func updateStorage() {
        do {
            try AppUser.current.storage.set(item: self.info, for: self.storageKey)
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
    }
    
    public override var certificate: Optional<APNs.Certificate> {
        return self.info.cerData.flatMap { .cer(data: $0) }
    }
}
