//
//  APNsJSONWebToken.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/25.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import CryptoKit

struct APNsJSONWebToken: Codable {
    
    struct Header: Codable {
        
        let algorithm: String = "ES256"
        let keyID: String
        
        private enum CodingKeys: String, CodingKey {
            case algorithm  = "alg"
            case keyID      = "kid"
        }
    }
    
    struct Claims: Codable {
            
        let teamID: String
        let issueDate: Date
        let expireDate: Date
        
        init(teamID: String, issueDate: Date) {
            self.teamID = teamID
            self.issueDate = issueDate
            self.expireDate = issueDate.addingTimeInterval(60.0 * 60.0).advanced(by: -60.0)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.teamID = try container.decode(String.self, forKey: .teamID)
            self.issueDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .issueDate)).rounded(.down))
            self.expireDate = Date(timeIntervalSince1970: TimeInterval(try container.decode(Int64.self, forKey: .expireDate)).rounded(.down))

        }
        
        func encode(to encoder: Encoder) throws {
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
    
    let header: Header
    let claims: Claims
    
    init(teamID: String, keyID: String, issueDate: Date) {
        self.header = Header(keyID: keyID)
        self.claims = Claims(teamID: teamID, issueDate: issueDate)
    }
    
    init?(jwtString: String) {
        let componets = jwtString.components(separatedBy: ".")
        guard componets.count == 3 else {
            return nil
        }
        guard let headerData = Data(base64URLEncoded: componets[0]), let claimsData = Data(base64URLEncoded: componets[1]) else {
            return nil
        }
        do {
            self.header = try JSONDecoder().decode(Header.self, from: headerData)
            self.claims = try JSONDecoder().decode(Claims.self, from: claimsData)
        } catch {
            return nil
        }
    }
    
    var isValid: Bool {
        return true
    }
    
    func sign(using privateKey: P256.Signing.PrivateKey) throws -> String {
        let headerString = try JSONEncoder().encode(self.header).base64URLEncodedString()
        let claimsString = try JSONEncoder().encode(self.claims).base64URLEncodedString()
        if let data = "\(headerString).\(claimsString)".data(using: .utf8) {
            let signature = try privateKey.signature(for: data)
            return "\(headerString).\(claimsString).\(signature.rawRepresentation.base64URLEncodedString())"
        } else {
            throw APNsError.invalidatePKCS8Decoding
        }
    }
    
    func sign(using PKCS8DERData: Data) throws -> String {
        guard let representation = ASN1.exactX963Representation(fromPKCS8DERData: PKCS8DERData) else {
            throw APNsError.invalidatePKCS8Decoding
        }
        let privateKey = try P256.Signing.PrivateKey(x963Representation: representation)
        return try self.sign(using: privateKey)
    }
    
    func sign(usingPKCS8DERString PKCS8DERString: String) throws -> String {
        guard let representation = ASN1.exactX963Representation(fromPKCS8DERString: PKCS8DERString) else {
            throw APNsError.invalidatePKCS8Decoding
        }
        let privateKey = try P256.Signing.PrivateKey(x963Representation: representation)
        return try self.sign(using: privateKey)
    }
}
