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
                    topic: AppService.current.bundleIDObject.value
                )
            case .p12:
                return try CertificateBasedProvider(
                    P12Data: certificate.data,
                    passphrase: certificate.passphrase,
                    topic: AppService.current.bundleIDObject.value
                )
            case .p8:
                return try TokenBasedProvider(
                    P8Data: certificate.data,
                    teamID: AppService.current.teamIDObject.value,
                    keyID: AppService.current.keyIDObject.value,
                    topic: AppService.current.bundleIDObject.value
                )
            }
        case .simulator:
            return SimulatorAPNsProvider(device: service.deviceObject.value, bundleID: service.bundleIDObject.value)
        }
    }
}
