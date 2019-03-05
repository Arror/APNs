//
//  JSONWebToken.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public struct JSONWebToken: Codable {
    
    private struct Header: Codable {
        
        let algorithm: String = "ES256"
        let keyID: String
        
        private enum CodingKeys: String, CodingKey {
            case algorithm  = "alg"
            case keyID      = "kid"
        }
    }
    
    private struct Claims: Codable {
        
        let teamID: String
        let issueDate: Date
        let expireDate: Date
        
        private enum CodingKeys: String, CodingKey {
            case teamID     = "iss"
            case issueDate  = "iat"
            case expireDate = "exp"
        }
    }
    
    private let header: Header
    private let claims: Claims
    
    public init(keyID: String, teamID: String, issueDate: Date, expireDate: Date) {
        self.header = Header(keyID: keyID)
        self.claims = Claims(teamID: teamID, issueDate: issueDate, expireDate: expireDate)
    }
    
    public var isExpired: Bool {
        return self.claims.expireDate.compare(Date(timeIntervalSinceNow: 0)) == .orderedAscending
    }
    
    public var digestString: String? {
        do {
            let headerString = try JSONEncoder().encode(self.header).base64URLEncodedString()
            let claimsString = try JSONEncoder().encode(self.claims).base64URLEncodedString()
            return "\(headerString).\(claimsString)"
        } catch {
            return nil
        }
    }
}
