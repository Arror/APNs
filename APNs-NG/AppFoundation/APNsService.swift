//
//  APNsService.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/18.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum APNsService: String, Codable, Equatable, CaseIterable {
    
    case sandbox
    case production
    
    var name: String {
        switch self {
        case .sandbox:
            return String.localizedString(forKey: "APNsService.Sandbox")
        case .production:
            return String.localizedString(forKey: "APNsService.Production")
        }
    }
}
