//
//  CodableStorage.swift
//  APNs
//
//  Created by Arror on 2019/3/4.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public protocol CodableStorage: class {
    
    func set<I: Codable>(item: Optional<I>, for key: String) throws
    
    func item<I: Codable>(for key: String) throws -> Optional<I>
}

private struct Wrapper<Value: Codable>: Codable {
    let value: Value
}

extension CodableStorage where Self: DataBaseStorage {
    
    public func set<I: Codable>(item: Optional<I>, for key: String) throws {
        try self.set(data: item.flatMap { try JSONEncoder().encode(Wrapper(value: $0)) }, for: key)
    }
    
    public func item<I: Codable>(for key: String) throws -> Optional<I> {
        return try self.data(for: key).flatMap { try JSONDecoder().decode(Wrapper<I>.self, from: $0).value }
    }
}
