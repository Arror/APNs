//
//  APNsState.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum APNsState: Equatable {
    
    case idle
    case process
    case success
    case failure(String)
    
    public static func ==(lhs: APNsState, rhs: APNsState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.process, .process):
            return true
        case (.success, .success):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
