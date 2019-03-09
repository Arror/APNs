//
//  CerTabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class CerTabItemView: CertificateTabItemView {
    
    private var certURL: Optional<URL> = .none
    
    @IBOutlet weak var certLabel: TappedLabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.certLabel.tapped = { _ in
            guard
                let window = self.window else {
                    return
            }
            NSOpenPanel.chooseCertificateFile(type: "cer", from: window) { result in
                switch result {
                case .some(let value):
                    self.certURL = value
                    self.updateViews()
                case .none:
                    break
                }
            }
        }
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.certURL.flatMap { $0.lastPathComponent } ?? ""
    }
    
    public override func makeProvider() -> Optional<APNs.Provider> {
        guard
            let url = self.certURL else {
                return .none
        }
        do {
            return try APNs.makeProvider(certificate: .cer(filePath: url.absoluteString))
        } catch {
            return .none
        }
    }
}
