//
//  TokenBasedProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class TokenBasedProvider: APNsProviderBase {
    
    public override var session: URLSession {
        return self._session
    }
    
    public override var authorization: String? {
        return self._tokenController.makeJWTToken()
    }
    
    private let _session: URLSession
    private let _queue: OperationQueue
    private let _topic: String
    private let _tokenController: APNsJWTTokenController
    
    public init(P8Data: Data, teamID: String, keyID: String, topic: String) throws {
        guard
            !teamID.isEmpty else {
                throw APNsError.teamIDEmpty
        }
        guard
            !keyID.isEmpty else {
                throw APNsError.keyIDEmpty
        }
        guard
            !topic.isEmpty else {
                throw APNsError.bundleIDEmpty
        }
        self._topic = topic
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        self._session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
        self._queue = queue
        self._tokenController = APNsJWTTokenController(P8Data: P8Data, teamID: teamID, keyID: keyID)
    }
}
