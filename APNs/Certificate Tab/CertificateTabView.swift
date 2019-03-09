//
//  CertificateTabView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class CertificateTabView: NSTabView {
    
    public var certificate: Optional<APNs.Certificate> {
        guard
            let view = self.selectedTabViewItem?.view as? CertificateTabItemView else {
                return .none
        }
        return view.certificate
    }
}
