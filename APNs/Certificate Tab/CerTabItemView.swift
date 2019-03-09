//
//  CerTabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class CerTabItemView: CertificateTabItemView {
    
    private var cerData: Optional<Data> = .none
    private var cerName: String = ""
    
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
                case .some(let pair):
                    self.cerData = pair.1
                    self.cerName = pair.0.lastPathComponent
                    self.updateViews()
                case .none:
                    break
                }
            }
        }
    }
    
    private func updateViews() {
        self.certLabel.stringValue = self.cerName
    }
    
    public override var certificate: Optional<APNs.Certificate> {
        return self.cerData.flatMap { .cer(data: $0) }
    }
}
