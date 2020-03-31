//
//  APNsClaims.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import SwiftJWT

public struct APNsClaims: Claims {
        
    public let teamID: String
    public let issueDate: Date
    public let expireDate: Date
    
    public init(teamID: String, issueDate: Date) {
        self.teamID = teamID
        self.issueDate = issueDate
        self.expireDate = issueDate.addingTimeInterval(60.0 * 60.0)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.teamID = try container.decode(String.self, forKey: .teamID)
        self.issueDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .issueDate)).rounded(.down))
        self.expireDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .expireDate)).rounded(.down))

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.teamID, forKey: .teamID)
        try container.encode(Int64(self.issueDate.timeIntervalSince1970.rounded(.down)), forKey: .issueDate)
        try container.encode(Int64(self.expireDate.timeIntervalSince1970.rounded(.down)), forKey: .expireDate)
    }
    
    private enum CodingKeys: String, CodingKey {
        case teamID     = "iss"
        case issueDate  = "iat"
        case expireDate = "exp"
    }
}

extension JWT where T == APNsClaims {
    
    public init(keyID: String, teamID: String, issueDate: Date) {
        self.init(header: Header(kid: keyID), claims: APNsClaims(teamID: teamID, issueDate: issueDate))
    }
}
