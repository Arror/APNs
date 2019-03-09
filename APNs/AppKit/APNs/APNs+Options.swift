//
//  APNs+Options.swift
//  APNs
//
//  Created by Arror on 2019/3/8.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

extension APNs {
    
    public struct Options {
        
        public let expiration: UInt
        public let priority: UInt
        
        public init(expiration: UInt = 0, priority: UInt = 10) {
            self.expiration = expiration
            self.priority = priority
        }
        
        public static let `default` = APNs.Options()
    }
}
