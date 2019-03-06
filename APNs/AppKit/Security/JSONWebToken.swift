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
    
    public init?(tokenString: String) {
        let components = tokenString.components(separatedBy: ".")
        guard
            components.count == 3,
            let headerData = Data(base64URLEncoded: components[0]),
            let payloadData = Data(base64URLEncoded: components[1]) else {
                return nil
        }
        do {
            self.header = try JSONDecoder().decode(Header.self, from: headerData)
            self.payload = try JSONDecoder().decode(Payload.self, from: payloadData)
        } catch {
            return nil
        }
    }
    
    public var isExpired: Bool {
        return Date(timeIntervalSinceNow: 0).compare(self.payload.expireDate) == .orderedAscending
    }
    
    public func digestString() throws -> String {
        let headerString = try JSONEncoder().encode(self.header).base64URLEncodedString()
        let payloadString = try JSONEncoder().encode(self.payload).base64URLEncodedString()
        return "\(headerString).\(payloadString)"
    }
}
