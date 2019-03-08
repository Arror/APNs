//
//  APNs+Payload.swift
//  APNs
//
//  Created by Arror on 2019/3/8.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public protocol PayloadConvertable {
    func asData() throws -> Data
}

extension Data: PayloadConvertable {
    
    public func asData() throws -> Data {
        return self
    }
}
