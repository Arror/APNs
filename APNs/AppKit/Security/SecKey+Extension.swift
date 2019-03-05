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
        let _publicKeyData: Data
        if
            case let ASN1.ASN1Element.constructed(tag: 1, elem: publicElement) = seq[2],
            case let ASN1.ASN1Element.bytes(data: pubKeyData) = publicElement {
            _publicKeyData = pubKeyData
        } else if
            seq.count >= 4,
            case let ASN1.ASN1Element.constructed(tag: 1, elem: publicElement) = seq[3],
            case let ASN1.ASN1Element.bytes(data: pubKeyData) = publicElement {
            _publicKeyData = pubKeyData
        } else {
            return nil
        }
        let publicKeyData = _publicKeyData.drop(while: { $0 == 0x00})
        
        let keyData = publicKeyData + privateKeyData
        
        var error: Unmanaged<CFError>? = nil
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary
        guard
            let secKey = SecKeyCreateWithData(keyData as CFData, attributes, &error) else {
                return nil
        }
        return ECPrivateKeyWrapper(key: secKey)
    }
    
    private struct ASN1 {
        
        indirect enum ASN1Element {
            case seq(elements: [ASN1Element])
            case integer(int: Int)
            case bytes(data: Data)
            case constructed(tag: Int, elem: ASN1Element)
            case unknown
        }
        
        static func toASN1Element(data: Data) -> (ASN1Element, Int) {
            guard
                data.count >= 2 else {
                    return (.unknown, data.count)
            }
            
            switch data[0] {
            case 0x30:
                let (length, lengthOfLength) = readLength(data: data.advanced(by: 1))
                var result: [ASN1Element] = []
                var subdata = data.advanced(by: 1 + lengthOfLength)
                var alreadyRead = 0
                
                while alreadyRead < length {
                    let (e, l) = toASN1Element(data: subdata)
                    result.append(e)
                    subdata = subdata.count > l ? subdata.advanced(by: l) : Data()
                    alreadyRead += l
                }
                return (.seq(elements: result), 1 + lengthOfLength + length)
                
            case 0x02:
                let (length, lengthOfLength) = readLength(data: data.advanced(by: 1))
                if length < 8 {
                    var result: Int = 0
                    let subdata = data.advanced(by: 1 + lengthOfLength)
                    for i in 0..<length {
                        result = 256 * result + Int(subdata[i])
                    }
                    return (.integer(int: result), 1 + lengthOfLength + length)
                }
                return (.bytes(data: data.subdata(in: (1 + lengthOfLength) ..< (1 + lengthOfLength + length))), 1 + lengthOfLength + length)
                
                
            case let s where (s & 0xe0) == 0xa0:
                let tag = Int(s & 0x1f)
                let (length, lengthOfLength) = readLength(data: data.advanced(by: 1))
                let subdata = data.advanced(by: 1 + lengthOfLength)
                let (e, _) = toASN1Element(data: subdata)
                return (.constructed(tag: tag, elem: e), 1 + lengthOfLength + length)
                
            default:
                let (length, lengthOfLength) = readLength(data: data.advanced(by: 1))
                return (.bytes(data: data.subdata(in: (1 + lengthOfLength) ..< (1 + lengthOfLength + length))), 1 + lengthOfLength + length)
            }
        }
        
        static private func readLength(data: Data) -> (Int, Int) {
            if data[0] & 0x80 == 0x00 {
                return (Int(data[0]), 1)
            } else {
                let lenghOfLength = Int(data[0] & 0x7F)
                var result: Int = 0
                for i in 1..<(1 + lenghOfLength) {
                    result = 256 * result + Int(data[i])
                }
                return (result, 1 + lenghOfLength)
            }
        }
    }
}
