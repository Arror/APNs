//
//  String+Ext.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

extension String {
    
    public var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "\n "))
    }
}
