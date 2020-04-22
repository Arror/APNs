//
//  APNsError.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum APNsError: LocalizedError {
    
    case certificateNotExist
    case teamIDEmpty
    case keyIDEmpty
    case bundleIDEmpty
    case tokenEmpty
    case invalidatePayload
    case loadCERFailed
    case loadPEMFailed
    case createCERFailed
    case createP12Failed
    case invalidateRequest
    case invalidateResponse
    
    public var errorDescription: String? {
        switch self {
        case .certificateNotExist:
            return String.localizedString(forKey: "APNsError.CertificateNotExist")
        case .teamIDEmpty:
            return String.localizedString(forKey: "APNsError.TeamIDEmpty")
        case .keyIDEmpty:
            return String.localizedString(forKey: "APNsError.KeyIDEmpty")
        case .bundleIDEmpty:
            return String.localizedString(forKey: "APNsError.BundleIDEmpty")
        case .tokenEmpty:
            return String.localizedString(forKey: "APNsError.TokenEmpty")
        case .invalidatePayload:
            return String.localizedString(forKey: "APNsError.InvalidatePayload")
        case .loadCERFailed:
            return String.localizedString(forKey: "APNsError.LoadCERFailed")
        case .loadPEMFailed:
            return String.localizedString(forKey: "APNsError.LoadPEMFailed")
        case .createCERFailed:
            return String.localizedString(forKey: "APNsError.CreateCERFailed")
        case .createP12Failed:
            return String.localizedString(forKey: "APNsError.CreateP12Failed")
        case .invalidateRequest:
            return String.localizedString(forKey: "APNsError.InvalidateRequest")
        case .invalidateResponse:
            return String.localizedString(forKey: "APNsError.InvalidateResponse")
        }
    }
}
