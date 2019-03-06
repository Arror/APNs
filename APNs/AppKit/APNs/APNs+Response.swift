//
//  APNs+Response.swift
//  APNs
//
//  Created by Arror on 2019/3/6.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

extension APNs {
    
    public struct Error: LocalizedError {
        
        public let code: Int
        public let message: String
        
        public init(code: Int, message: String) {
            self.code = code
            self.message = message
        }
        
        public init(error: Swift.Error) {
            self.init(code: -1, message: error.localizedDescription)
        }
        
        public init(httpResponse: HTTPURLResponse, data: Data?) {
            do {
                guard
                    let resultData = data,
                    let json = try JSONSerialization.jsonObject(with: resultData, options: []) as? [String: Any],
                    let reason = json["reason"] as? String else {
                        self.init(code: -1, message: "Unknown error.")
                        return
                }
                let msg: String
                switch reason {
                case "BadCollapseId":
                    msg = "The collapse identifier exceeds the maximum allowed size."
                case "BadDeviceToken":
                    msg = "The specified device token is invalid. Verify that the request contains a valid token and that the token matches the environment."
                case "BadExpirationDate":
                    msg = "The apns-expiration value is invalid."
                case "BadMessageId":
                    msg = "The apns-id value is invalid."
                case "BadPriority":
                    msg = "The apns-priority value is invalid."
                case "BadTopic":
                    msg = "The apns-topic is invalid."
                case "DeviceTokenNotForTopic":
                    msg = "The device token doesn't match the specified topic."
                case "DuplicateHeaders":
                    msg = "One or more headers are repeated."
                case "IdleTimeout":
                    msg = "Idle time out."
                case "MissingDeviceToken":
                    msg = "The device token isn't specified in the request :path. Verify that the :path header contains the device token."
                case "MissingTopic":
                    msg = "The apns-topic header of the request isn't specified and is required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics."
                case "PayloadEmpty":
                    msg = "The message payload is empty."
                case "TopicDisallowed":
                    msg = "Pushing to this topic is not allowed."
                case "BadCertificate":
                    msg = "The certificate is invalid."
                case "BadCertificateEnvironment":
                    msg = "The client certificate is for the wrong environment."
                case "ExpiredProviderToken":
                    msg = "The provider token is stale and a new token should be generated."
                case "Forbidden":
                    msg = "The specified action is not allowed."
                case "InvalidProviderToken":
                    msg = "The provider token is not valid, or the token signature cannot be verified."
                case "MissingProviderToken":
                    msg = "No provider certificate was used to connect to APNs, and the authorization header is missing or no provider token is specified."
                case "BadPath":
                    msg = "The request contained an invalid :path value."
                case "MethodNotAllowed":
                    msg = "The specified :method isn't POST."
                case "Unregistered":
                    msg = "The device token is inactive for the specified topic."
                case "PayloadTooLarge":
                    msg = "The message payload is too large. For information about the allowed payload size, see Create and Send a POST Request to APNs."
                case "TooManyProviderTokenUpdates":
                    msg = "The provider’s authentication token is being updated too often. Update the authentication token no more than once every 20 minutes."
                case "TooManyRequests":
                    msg = "Too many requests were made consecutively to the same device token."
                case "InternalServerError":
                    msg = "An internal server error occurred."
                case "ServiceUnavailable":
                    msg = "The service is unavailable."
                case "Shutdown":
                    msg = "The APNs server is shutting down."
                default:
                    msg = "Unknown error."
                }
                self.init(code: httpResponse.statusCode, message: msg)
            } catch {
                self.init(error: error)
            }
        }
        
        public var errorDescription: String? {
            return self.message
        }
    }
    
    public enum Response {
        
        case success
        case failure(Error)
        
        public init(response: URLResponse?, data: Data?, error: Swift.Error?) {
            let httpResponse = response as! HTTPURLResponse
            if let err = error {
                self = .failure(APNs.Error(error: err))
            } else {
                if httpResponse.statusCode == 200 {
                    self = .success
                } else {
                    self = .failure(APNs.Error(httpResponse: httpResponse, data: data))
                }
            }
        }
    }
}
