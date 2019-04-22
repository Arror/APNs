//
//  APNsTitleBar.swift
//  APNsFlutter
//
//  Created by Arror on 2019/4/3.
//  Copyright © 2019 Arror. All rights reserved.
//

import Cocoa

class APNsTitleBar: NSTitlebarAccessoryViewController {
    
    static func make() -> APNsTitleBar {
        return NSStoryboard(name: "APNsTitleBar", bundle: nil).instantiateInitialController() as! APNsTitleBar
    }
}
