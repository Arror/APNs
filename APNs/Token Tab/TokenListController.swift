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
    public let server: APNs.Server
    
    private var srotageKey: String {
        return "\(self.server.rawValue).tokens".lowercased()
    }
    
    public init(server: APNs.Server) {
        self.server = server
        do {
            self.tokens = try AppUser.current.storage.item(for: self.srotageKey) ?? []
        } catch {
            self.tokens = []
        }
    }
    
    @discardableResult
    public func add(token: String) -> Bool {
        if self.tokens.contains(token) {
            return false
        } else {
            self.tokens.append(token)
            self.updateStorage()
            return true
        }
    }
    
    private func updateStorage() {
        do {
            try AppUser.current.storage.set(item: self.tokens, for: self.srotageKey)
        } catch {
            AppService.current.logger.log(level: .error, message: error.localizedDescription)
        }
    }
    
    @discardableResult
    public func delete(token: String) -> Bool {
        if let idx = self.tokens.firstIndex(of: token) {
            self.tokens.remove(at: idx)
            self.updateStorage()
            return true
        } else {
            return false
        }
    }
}
