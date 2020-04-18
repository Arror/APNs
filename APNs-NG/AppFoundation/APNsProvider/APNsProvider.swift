//
//  APNsProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import Combine

public protocol APNsProvider: class {
    func send(token: String, payload: Data, priority: Int) -> AnyPublisher<Void, Error>
}

extension AppService {
    
    private func validateTeamID() throws -> String {
        let value = self.teamID.trimmed
        if value.isEmpty {
            throw APNsError.teamIDEmpty
        }
        return value
    }
    
    private func validateKeyID() throws -> String {
        let value = self.keyID.trimmed
        if value.isEmpty {
            throw APNsError.keyIDEmpty
        }
        return value
    }
    
    private func validateBundleID() throws -> String {
        let value = self.bundleID.trimmed
        if value.isEmpty {
            throw APNsError.bundleIDEmpty
        }
        return value
    }
    
    private func validateToken() throws -> String {
        let value = self.token.trimmed
        if value.isEmpty {
            throw APNsError.tokenEmpty
        }
        return value
    }
    
    func makeRawPushPublsher() throws -> AnyPublisher<Void, Error> {
        let validToken = try self.validateToken()
        guard let data = self.payload.trimmed.data(using: .utf8) else {
            throw APNsError.invalidatePayload
        }
        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            throw APNsError.invalidatePayload
        }
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            throw APNsError.invalidatePayload
        }
        guard let certificate = self.apnsCertificate else {
            throw APNsError.certificateNotExist
        }
        let validBundleID = try self.validateBundleID()
        let provider: APNsProvider
        switch certificate.certificateType {
        case .cer:
            provider = try APNsCertificateBasedProvider(
                cerData: certificate.data,
                service: self.apnsService,
                bundleID: self.bundleID
            )
        case .pem:
            provider = try APNsCertificateBasedProvider(
                pemData: certificate.data,
                service: self.apnsService,
                bundleID: validBundleID
            )
        case .p12:
            provider = try APNsCertificateBasedProvider(
                P12Data: certificate.data,
                passphrase: certificate.passphrase,
                service: self.apnsService,
                bundleID: validBundleID
            )
        case .p8:
            let validTeamID = try self.validateTeamID()
            let validKeyID = try self.validateKeyID()
            provider = try APNsTokenBasedProvider(
                P8Data: certificate.data,
                service: self.apnsService,
                teamID: validTeamID,
                keyID: validKeyID,
                bundleID: validBundleID
            )
        }
        return provider.send(token: validToken, payload: data, priority: self.priority)
    }
}
