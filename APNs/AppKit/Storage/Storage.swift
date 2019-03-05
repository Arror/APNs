//
//  Storage.swift
//  APNs
//
//  Created by Arror on 2019/3/4.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public final class DefaultsStorage: DataBaseStorage, CodableStorage {
    
    private let defaults: UserDefaults
    
    public init() {
        self.defaults = UserDefaults.standard
    }
    
    public func data(for key: String) throws -> Optional<Data> {
        return self.defaults.data(forKey: key)
    }
    
    public func set(data: Optional<Data>, for key: String) throws {
        self.defaults.set(data, forKey: key)
    }
}
