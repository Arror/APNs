//
//  APNsFakeTitleBar.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class APNsFakeTitleBar: NSTitlebarAccessoryViewController {
    
    static func make() -> APNsFakeTitleBar {
        return NSStoryboard(name: "Bar", bundle: nil).instantiateInitialController() as! APNsFakeTitleBar
    }
}
