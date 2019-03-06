//
//  Data+Base64URL.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/6.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

extension Data {
    
    public func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    public init?(base64URLEncoded: String) {
        let paddingLength = 4 - base64URLEncoded.count % 4
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        self.init(base64Encoded: base64EncodedString)
    }
}
