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
    
    private struct Payload: Codable {
        
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
    private let payload: Payload
    
    public init(keyID: String, teamID: String, issueDate: Date, expireDate: Date) {
        self.header = Header(keyID: keyID)
        self.payload = Payload(teamID: teamID, issueDate: issueDate, expireDate: expireDate)
    }
    
    public var isExpired: Bool {
        return self.payload.expireDate.compare(Date(timeIntervalSinceNow: 0)) == .orderedAscending
    }
    
    public var digestString: String? {
        do {
            let headerString = try JSONEncoder().encode(self.header).base64URLEncodedString()
            let payloadString = try JSONEncoder().encode(self.payload).base64URLEncodedString()
            return "\(headerString).\(payloadString)"
        } catch {
            return nil
        }
    }
}
