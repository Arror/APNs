//
//  DataBaseStorage.swift
//  APNs
//
//  Created by Arror on 2019/3/4.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public protocol DataBaseStorage: class {
    
    func set(data: Optional<Data>, for key: String) throws
    
    func data(for key: String) throws -> Optional<Data>
}

extension DataBaseStorage {
    
    public func clear(for key: String) throws {
        try self.set(data: .none, for: key)
    }
}
