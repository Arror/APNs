//
//  Dispatch+Safe.swift
//  APNs
//
//  Created by Arror on 2019/3/6.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

extension DispatchQueue: SafeCompatible {}

extension Safe where Base == DispatchQueue {
    
    public func sync(execute: () -> Void) {
        if Thread.current == self.base {
            execute()
        } else {
            self.base.sync {
                execute()
            }
        }
    }
}
