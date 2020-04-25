//
//  ASN1+X963Representation.swift
//  APNs-NG
//
//  Created by 马强 on 2020/4/25.
//  Copyright © 2020 Arror. All rights reserved.
//

import Foundation

extension ASN1 {
    
    static func exactX963Representation(fromPKCS8DERString PKCS8DERString: String) -> Data? {
        
        let rawString = PKCS8DERString.components(separatedBy: "\n").filter({ !$0.hasPrefix("-----") }).joined()
        
        guard let PKCS8DERData = Data(base64Encoded: rawString) else {
            return nil
        }
        
        return self.exactX963Representation(fromPKCS8DERData: PKCS8DERData)
    }
    
    static func exactX963Representation(fromPKCS8DERData PKCS8DERData: Data) -> Data? {
        
        let (result, _) = ASN1.toASN1Element(data: PKCS8DERData)
        
        guard
            case let ASN1.ASN1Element.seq(elements: es) = result, es.count > 2,
            case let ASN1.ASN1Element.seq(elements: ids) = es[1], ids.count > 1 else {
                return nil
        }
        
        guard
            case let ASN1.ASN1Element.bytes(data: privateOctest) = es[2] else {
                return nil
        }
        
        let (octest, _) = ASN1.toASN1Element(data: privateOctest)
        
        guard
            case let ASN1.ASN1Element.seq(elements: seq) = octest, seq.count >= 3,
            case let ASN1.ASN1Element.bytes(data: privateKeyData) = seq[1] else {
                return nil
        }
        
        let publicKeyData: Data
        if
            case let ASN1.ASN1Element.constructed(tag: 1, elem: publicElement) = seq[2],
            case let ASN1.ASN1Element.bytes(data: pubKeyData) = publicElement {
            publicKeyData = pubKeyData
        } else if
            seq.count >= 4,
            case let ASN1.ASN1Element.constructed(tag: 1, elem: publicElement) = seq[3],
            case let ASN1.ASN1Element.bytes(data: pubKeyData) = publicElement {
            publicKeyData = pubKeyData
        } else {
            return nil
        }
            
        return publicKeyData.drop(while: { $0 == 0x00}) + privateKeyData
    }
}
