//
//  APNsPreference.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public struct APNsPreference: Codable {
    public let teamID: String
    public let keyID: String
    public let bundleID: String
    public let service: APNsService
    public let certificate: Optional<APNsCertificate>
    public let token: String
    public let priority: Int
}
