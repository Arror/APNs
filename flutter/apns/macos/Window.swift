//
//  Window.swift
//  APNsFlutter
//
//  Created by Arror on 2019/3/14.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa
import FlutterMacOS

class Window: NSWindow {
    
    @IBOutlet weak var flutter: FLEViewController!
    
    override func awakeFromNib() {
        let assets = URL(fileURLWithPath: "flutter_assets", relativeTo: Bundle.main.resourceURL)
        let arguments: [String] = {
            #if DEBUG
            return ["--observatory-port=49494"]
            #else
            return ["--disable-dart-asserts"]
            #endif
        }()
        self.flutter.launchEngine(withAssetsPath: assets, commandLineArguments: arguments)
        
        let channel = FlutterMethodChannel(name: "com.Arror.APNs.Input", binaryMessenger: self.flutter)
        channel.setMethodCallHandler { call, result in
            if call.method == "showInputSheet" {
                guard
                    let arguments = call.arguments as? [Any],
                    let parameters = arguments.first as? [String: Any],
                    let title = parameters["title"] as? String,
                    let initialText = parameters["initialText"] as? String else {
                        result(FlutterError(code: "arguments error", message: "参数错误", details: nil))
                        return
                }
                let vc = InputViewController.makeViewController(title: title, initialText: initialText, compeltion: { r in
                    switch r {
                    case .value(let text):
                        result([text])
                    case .cancel:
                        result(FlutterError(code: "cancel", message: "取消", details: nil))
                    }
                })
                self.flutter.presentViewControllerAsSheet(vc)
            } else {
                result(FlutterError(code: "unimplemented", message: "方法未实现", details: nil))
            }
        }
        super.awakeFromNib()
    }
}

