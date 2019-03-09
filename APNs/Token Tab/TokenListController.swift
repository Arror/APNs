//
//  TokenListController.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public class TokenListController {
    
    public private(set) var tokens: [String] = []
    
    public init() {}
    
    @discardableResult
    public func add(token: String) -> Bool {
        if self.tokens.contains(token) {
            return false
        } else {
            self.tokens.append(token)
            return true
        }
    }
    
    @discardableResult
    public func delete(token: String) -> Bool {
        if let idx = self.tokens.firstIndex(of: token) {
            self.tokens.remove(at: idx)
            return true
        } else {
            return false
        }
    }
}
