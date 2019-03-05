//
//  ASN1.swift
//  APNs
//
//  Created by Qiang Ma 马强 on 2019/3/5.
//  Copyright © 2019 Arror. All rights reserved.
//

import Foundation

public struct ASN1 {
    
    public indirect enum Element {
        case seq(elements: [Element])
        case integer(int: Int)
        case bytes(data: Data)
        case constructed(tag: Int, elem: Element)
        case unknown
    }
    
    private static func dropLeadingBytes(data: Data) -> Data {
        if data.count == 33 {
            return data.dropFirst()
        }
        return data
    }
    
    public static func toRawSignature(data: Data) -> Data? {
        
        let (result, _) = self.toASN1Element(data: data)
        
        guard
            case let Element.seq(elements: es) = result,
            case let Element.bytes(data: sigR) = es[0],
            case let Element.bytes(data: sigS) = es[1] else {
                return nil
        }
        
        return self.dropLeadingBytes(data: sigR) + self.dropLeadingBytes(data: sigS)
    }
    
    public static func toASN1Element(data: Data) -> (Element, Int) {
        guard
            data.count >= 2 else {
                return (.unknown, data.count)
        }
        
        switch data[0] {
        case 0x30:
            let (length, lengthOfLength) = readLength(data: data.advanced(by: 1))
            var result: [Element] = []
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
    
    private static func readLength(data: Data) -> (Int, Int) {
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
