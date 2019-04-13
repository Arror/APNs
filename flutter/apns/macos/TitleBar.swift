//
//  TitleBar.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class TitleBar: NSTitlebarAccessoryViewController {
    
    static func make() -> TitleBar {
        return NSStoryboard(name: "TitleBar", bundle: nil).instantiateInitialController() as! TitleBar
    }
}
