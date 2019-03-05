//
//  SecKey+Extension.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

extension PrivateKeyWrapper {
    
    static func make(withP8String p8: String) -> ECPrivateKeyWrapper? {
        
        let derString = p8.components(separatedBy: "\n").filter({ !$0.hasPrefix("-----") }).joined()
        
        guard
            let derData = Data(base64Encoded: derString) else {
                return nil
        }
        
        let (result, _) = ASN1.toASN1Element(data: derData)
        guard
            case let ASN1.Element.seq(elements: es) = result, es.count > 2,
            case let ASN1.Element.seq(elements: ids) = es[1], ids.count > 1 else {
                return nil
        }
        guard
            case let ASN1.Element.bytes(data: privateOctest) = es[2] else {
                return nil
        }
        let (octest, _) = ASN1.toASN1Element(data: privateOctest)
        guard
            case let ASN1.Element.seq(elements: seq) = octest, seq.count >= 3,
            case let ASN1.Element.bytes(data: privateKeyData) = seq[1] else {
                return nil
        }
        let _publicKeyData: Data
        if
            case let ASN1.Element.constructed(tag: 1, elem: publicElement) = seq[2],
            case let ASN1.Element.bytes(data: pubKeyData) = publicElement {
            _publicKeyData = pubKeyData
        } else if
            seq.count >= 4,
            case let ASN1.Element.constructed(tag: 1, elem: publicElement) = seq[3],
            case let ASN1.Element.bytes(data: pubKeyData) = publicElement {
            _publicKeyData = pubKeyData
        } else {
            return nil
        }
        let publicKeyData = _publicKeyData.drop(while: { $0 == 0x00})
        
        let keyData = publicKeyData + privateKeyData
        
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary
        guard
            let secKey = SecKeyCreateWithData(keyData as CFData, attributes, nil) else {
                return nil
        }
        return ECPrivateKeyWrapper(key: secKey)
    }
}
