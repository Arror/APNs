//
//  SafeCompatible.swift
//  APNs
//
//  Created by Arror on 2019/3/6.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public protocol SafeCompatible {
    
    associatedtype CompatibleType
    
    var safe: CompatibleType { get }
}

extension SafeCompatible {
    
    public var safe: Safe<Self> { return Safe(self) }
}

public struct Safe<Base> {
    
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}
