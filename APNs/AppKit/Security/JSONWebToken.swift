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
        
        init(teamID: String, issueDate: Date, expireDate: Date) {
            self.teamID = teamID
            self.issueDate = issueDate
            self.expireDate = expireDate
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.teamID = try container.decode(String.self, forKey: .teamID)
            self.issueDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .issueDate)).rounded())
            self.expireDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .expireDate)).rounded())
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.teamID, forKey: .teamID)
            try container.encode(Int64(self.issueDate.timeIntervalSince1970.rounded()), forKey: .issueDate)
            try container.encode(Int64(self.expireDate.timeIntervalSince1970.rounded()), forKey: .expireDate)
        }
        
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
