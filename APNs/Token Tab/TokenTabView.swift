//
//  TokenTabView.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/9.
//  Copyright © 2019 Arror. All rights reserved.
//

import AppKit

public class TokenTabView: NSTabView {
    
    public var tokenPair: (APNs.Server, [String]) {
        let view = self.selectedTabViewItem?.view as! TokenListView
        return view.tokenInfo
    }
}
