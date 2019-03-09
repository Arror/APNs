//
//  CertificateTabItemView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class CertificateTabItemView: NSView {
    
    public func makeProvider() -> Optional<APNs.Provider> {
        return .none
    }
}
