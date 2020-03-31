//
//  APNsProvider.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public protocol APNsProvider: class {
    func send(payload: String, token: String, priorty: Int, completion: @escaping (Result<Void, Error>) -> Void)
}
