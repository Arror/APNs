//
//  APNsCertificate.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum CertificateType: String, Equatable, Codable, CaseIterable {
    case cer    = "cer"
    case pem    = "pem"
    case p12    = "p12"
    case p8     = "p8"
}

public struct APNsCertificate: Codable {
    
    public let certificateType: CertificateType
    public let name: String
    public let data: Data
    public let passphrase: String
    
    public init(certificateType: CertificateType, passphrase: String, name: String, data: Data) {
        self.certificateType = certificateType
        self.passphrase = passphrase
        self.name = name
        self.data = data
    }
}
