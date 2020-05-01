//
//  JSBridge.swift
//  Bridge
//
//  Created by 马强 on 2020/3/24.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation
import WebKit

open class JSBridge: NSObject, WKScriptMessageHandler {
    
    public let name: String
        
    public init(name: String) {
        self.name = name
        super.init()
    }
        
    public final func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let webView = message.webView, message.name.caseInsensitiveCompare(self.name) == .orderedSame else {
            return
        }
        self.webView(webView, postMessage: message.body)
    }
    
    public final func webView(_ view: WKWebView, evaluateJavaScript javaScriptString: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        view.evaluateJavaScript(javaScriptString) { any, error in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.success(any))
            }
        }
    }
        
    open func webView(_ view: WKWebView, postMessage messageBody: Any) {}
}
