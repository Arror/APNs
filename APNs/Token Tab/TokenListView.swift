//
//  TokenListView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class TokenListView: NSView {
    
    public let controller = TokenListController()
    
    public var tokenInfo: (APNs.Server, [String]) {
        return (self.server, self.controller.tokens)
    }
    
    public var server: APNs.Server {
        fatalError()
    }
    
    public func addToken(completion: @escaping () -> Void) {
        let vc = InputSheetViewController.makeViewController(title: "Token") { result in
            switch result {
            case .some(let value):
                self.controller.add(token: value)
            case .none:
                break
            }
            completion()
        }
        self.window?.contentViewController?.presentAsSheet(vc)
    }
    
    public func delete(token: String) {
        self.controller.delete(token: token)
    }
}
