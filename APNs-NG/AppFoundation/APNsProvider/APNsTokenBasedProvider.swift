//
//  APNsTokenBasedProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public final class APNsTokenBasedProvider: APNsProviderBase {

    public override var session: URLSession {
        return self._session
    }

    public override var authorization: String? {
        return self._tokenController.jwt
    }

    private let _session: URLSession
    private let _queue: OperationQueue
    private let _tokenController: APNsJSONWebTokenController

    public init(P8Data: Data, service: APNsService, teamID: String, keyID: String, bundleID: String) throws {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        self._session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
        self._queue = queue
        self._tokenController = APNsJSONWebTokenController(P8Data: P8Data, teamID: teamID, keyID: keyID)
        super.init(service: service, bundleID: bundleID)
    }
}
