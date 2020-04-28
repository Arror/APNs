//
//  JSBridge.swift
//  Bridge
//
//  Created by 马强 on 2020/3/24.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import WebKit

class JSBridge: NSObject, WKScriptMessageHandler {
    
    let bridgeName: String
    let javascriptCall: (Any) -> Void
        
    init(bridgeName: String, javascriptCall: @escaping (Any) -> Void) {
        self.bridgeName = bridgeName
        self.javascriptCall = javascriptCall
        super.init()
    }
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name.caseInsensitiveCompare(self.bridgeName) == .orderedSame else {
            return
        }
        self.javascriptCall(message.body)
    }
}
