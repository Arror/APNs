//
//  PayloadView.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/16.
//  Copyright © 2020 Arror. All rights reserved.
//

import SwiftUI
import WebKit

struct PayloadView: View {
    
    let editor: JSONEditor
    
    init(text: Binding<String>) {
        self.editor = JSONEditor(text: text)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                self.editor.frame(height: proxy.size.height)
            }.frame(height: proxy.size.height)
        }
    }
}

struct JSONEditor: NSViewRepresentable {
    
    @Binding private var text: String

    init(text: Binding<String>) {
        _text = text
    }

    init(text: String) {
        self.init(text: Binding<String>.constant(text))
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: context.coordinator.bridgeName)
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        if let bundleURL = Bundle.main.url(forResource: "Editor", withExtension: "bundle") {
            webView.loadFileURL(bundleURL.appendingPathComponent("index.html"), allowingReadAccessTo: bundleURL)
        } else {
            webView.loadHTMLString("", baseURL: nil)
        }
        webView.isHidden = true
        return webView
    }

    func updateNSView(_ view: WKWebView, context: Context) {
        let style: String
        switch context.environment.colorScheme {
        case .dark:
            style = "dark"
        case .light:
            style = "light"
        @unknown default:
            style = "light"
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: ["style": style], options: [])
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }
            view.evaluateJavaScript("updateTheme(\(string))") { any, error in
                print(error?.localizedDescription ?? "KSDFKSD")
            }
        } catch {
            
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, bridgeName: "bridge") { body in
            self.text = {
                guard let message = body as? String else {
                    return ""
                }
                return message
            }()
        }
    }

    class Coordinator: JSBridge, WKNavigationDelegate {
        
        let parent: JSONEditor

        init(_ parent: JSONEditor, bridgeName: String, javascriptCall: @escaping (Any) -> Void) {
            self.parent = parent
            super.init(bridgeName: bridgeName, javascriptCall: javascriptCall)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.isHidden = false
        }
    }
}

struct PayloadView_Previews: PreviewProvider {
    
    @State static var text: String = ""
    
    static var previews: some View {
        PayloadView(text: $text)
    }
}
