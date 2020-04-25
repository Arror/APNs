//
//  Data+Base64URLEncoded.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/25.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

extension Data {
    
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    init?(base64URLEncoded: String) {
        let paddingLength = 4 - base64URLEncoded.count % 4
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        self.init(base64Encoded: base64EncodedString)
    }
}
