//
//  APNsResponse.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum APNsResponse {
    
    public enum Error: String, LocalizedError {
        
        case badCollapseId                  = "BadCollapseId"
        case badDeviceToken                 = "BadDeviceToken"
        case badExpirationDate              = "BadExpirationDate"
        case badMessageId                   = "BadMessageId"
        case badPriority                    = "BadPriority"
        case badTopic                       = "BadTopic"
        case deviceTokenNotForTopic         = "DeviceTokenNotForTopic"
        case duplicateHeaders               = "DuplicateHeaders"
        case idleTimeout                    = "IdleTimeout"
        case missingDeviceToken             = "MissingDeviceToken"
        case missingTopic                   = "MissingTopic"
        case payloadEmpty                   = "PayloadEmpty"
        case topicDisallowed                = "TopicDisallowed"
        case badCertificate                 = "BadCertificate"
        case badCertificateEnvironment      = "BadCertificateEnvironment"
        case expiredProviderToken           = "ExpiredProviderToken"
        case forbidden                      = "Forbidden"
        case invalidProviderToken           = "InvalidProviderToken"
        case missingProviderToken           = "MissingProviderToken"
        case badPath                        = "BadPath"
        case methodNotAllowed               = "MethodNotAllowed"
        case unregistered                   = "Unregistered"
        case payloadTooLarge                = "PayloadTooLarge"
        case tooManyProviderTokenUpdates    = "TooManyProviderTokenUpdates"
        case tooManyRequests                = "TooManyRequests"
        case internalServerError            = "InternalServerError"
        case serviceUnavailable             = "ServiceUnavailable"
        case shutdown                       = "Shutdown"
        
        // APNs
        case noResponse                     = "NoResponse"
        case errorResponse                  = "ErrorResponse"
        case other                          = "Other"
        
        public init(code: String) {
            self = Error(rawValue: code) ?? .other
        }
        
        public var errorDescription: String? {
            switch self {
            case .badCollapseId:
                return "The collapse identifier exceeds the maximum allowed size."
            case .badDeviceToken:
                return "The specified device token is invalid. Verify that the request contains a valid token and that the token matches the environment."
            case .badExpirationDate:
                return "The apns-expiration value is invalid."
            case .badMessageId:
                return "The apns-id value is invalid."
            case .badPriority:
                return "The apns-priority value is invalid."
            case .badTopic:
                return "The apns-topic is invalid."
            case .deviceTokenNotForTopic:
                return "The device token doesn't match the specified topic."
            case .duplicateHeaders:
                return "One or more headers are repeated."
            case .idleTimeout:
                return "Idle time out."
            case .missingDeviceToken:
                return "The device token isn't specified in the request :path. Verify that the :path header contains the device token."
            case .missingTopic:
                return "The apns-topic header of the request isn't specified and is required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics."
            case .payloadEmpty:
                return "The message payload is empty."
            case .topicDisallowed:
                return "Pushing to this topic is not allowed."
            case .badCertificate:
                return "The certificate is invalid."
            case .badCertificateEnvironment:
                return "The client certificate is for the wrong environment."
            case .expiredProviderToken:
                return "The provider token is stale and a new token should be generated."
            case .forbidden:
                return "The specified action is not allowed."
            case .invalidProviderToken:
                return "The provider token is not valid, or the token signature cannot be verified."
            case .missingProviderToken:
                return "No provider certificate was used to connect to APNs, and the authorization header is missing or no provider token is specified."
            case .badPath:
                return "The request contained an invalid :path value."
            case .methodNotAllowed:
                return "The specified :method isn't POST."
            case .unregistered:
                return "The device token is inactive for the specified topic."
            case .payloadTooLarge:
                return "The message payload is too large. For information about the allowed payload size, see Create and Send a POST Request to APNs."
            case .tooManyProviderTokenUpdates:
                return "The provider’s authentication token is being updated too often. Update the authentication token no more than once every 20 minutes."
            case .tooManyRequests:
                return "Too many requests were made consecutively to the same device token."
            case .internalServerError:
                return "An internal server error occurred."
            case .serviceUnavailable:
                return "The service is unavailable."
            case .shutdown:
                return "The APNs server is shutting down."
            case .noResponse:
                return "No response."
            case .errorResponse:
                return "Response error."
            case .other:
                return "Other error."
            }
        }
    }
    
    case success
    case failure(Swift.Error)
    
    public init(response: URLResponse?, data: Data?, error: Swift.Error?) {
        do {
            if let err = error {
                throw err
            }
            guard
                let httpResponse = response as? HTTPURLResponse else {
                    throw APNsResponse.Error.noResponse
            }
            if httpResponse.statusCode == 200 {
                self = .success
            } else {
                guard
                    let resultData = data,
                    let json = try JSONSerialization.jsonObject(with: resultData, options: []) as? [String: Any],
                    let reason = json["reason"] as? String else {
                        throw APNsResponse.Error.errorResponse
                }
                throw APNsResponse.Error(code: reason)
            }
        } catch {
            self = .failure(error)
        }
    }
}
