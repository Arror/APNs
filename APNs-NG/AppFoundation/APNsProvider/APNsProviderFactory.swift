//
//  APNsProviderFactory.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class APNsProviderFactory {
    
    public static func provider(forCurrentService service: AppService) throws -> APNsProvider {
        switch service.destinationObject.value {
        case .device:
            guard let certificate = AppService.current.certificateObject.value else {
                throw APNsError.certificateNotExist
            }
            switch certificate.certificateType {
            case .cer:
                return try CertificateBasedProvider(
                    cerData: certificate.data,
                    topic: AppService.current.bundleIDObject.value.trimmed
                )
            case .pem:
                return try CertificateBasedProvider(
                    pemData: certificate.data,
                    topic: AppService.current.bundleIDObject.value.trimmed
                )
            case .p12:
                return try CertificateBasedProvider(
                    P12Data: certificate.data,
                    passphrase: certificate.passphrase.trimmed,
                    topic: AppService.current.bundleIDObject.value.trimmed
                )
            case .p8:
                return try TokenBasedProvider(
                    P8Data: certificate.data,
                    teamID: AppService.current.teamIDObject.value.trimmed,
                    keyID: AppService.current.keyIDObject.value.trimmed,
                    topic: AppService.current.bundleIDObject.value.trimmed
                )
            }
        #if COMMUNITY
        case .simulator:
            return APNsSimulatorProvider(device: service.deviceObject.value, bundleID: service.bundleIDObject.value.trimmed)
        #endif
        }
    }
}
