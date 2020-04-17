//
//  APNsError.swift
//  APNs-NG
//
//  Created by 马强 on 2020/3/29.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

public enum APNsError: LocalizedError {
    
    case certificateNotExist
    case teamIDEmpty
    case keyIDEmpty
    case bundleIDEmpty
    case tokenEmpty
    case noSimulator
    case invalidatePayload
    case loadCERFailed
    case loadPEMFailed
    case createCERFailed
    case createP12Failed
    case invalidateRequest
    case invalidateResponse
    
    public var errorDescription: String? {
        switch self {
        case .certificateNotExist:
            return "请添加证书信息"
        case .teamIDEmpty:
            return "请添加组织信息"
        case .keyIDEmpty:
            return "请添加钥匙信息"
        case .bundleIDEmpty:
            return "请填写套装信息"
        case .tokenEmpty:
            return "请填写令牌"
        case .noSimulator:
            return "请选择模拟器"
        case .invalidatePayload:
            return "请检查负载信息"
        case .loadCERFailed:
            return "获取CER证书失败"
        case .loadPEMFailed:
            return "获取PEM证书失败"
        case .createCERFailed:
            return "创建CER证书失败"
        case .createP12Failed:
            return "创建P12证书失败"
        case .invalidateRequest:
            return "发送通知请求失败"
        case .invalidateResponse:
            return "发送通知相应失败"
        }
    }
}
