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
        
        APNsPlugin.register(with: self.flutter.registrar(forPlugin: "APNsPlugin"))
        
        let assets = URL(fileURLWithPath: "flutter_assets", relativeTo: Bundle.main.resourceURL)
        let arguments: [String] = {
            #if DEBUG
            return ["--observatory-port=49494"]
            #else
            return ["--disable-dart-asserts"]
            #endif
        }()
        self.flutter.launchEngine(withAssetsPath: assets, commandLineArguments: arguments)
        super.awakeFromNib()
    }
}

