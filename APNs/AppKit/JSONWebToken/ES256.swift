import Foundation
import CommonCrypto

public final class ES256 {
    
    private enum Error: LocalizedError {
        
        case failedBase64Encoding
        case failedASN1Decoding
        case unsupportedCurve
        case failedNativeKeyCreation
        case failedSigningAlgorithm
        
        var errorDescription: String? {
            switch self {
            case .failedBase64Encoding:
                return "Failed to base64 encode the String"
            case .failedASN1Decoding:
                return "ASN1 data could not be decoded to expected structure"
            case .unsupportedCurve:
                return "The key object identifier is for a non-supported curve"
            case .failedNativeKeyCreation:
                return "The key data could not be converted to a native key"
            case .failedSigningAlgorithm:
                return "Signing algorithm failed to create the signature"
            }
        }
    }

    private let secKey: SecKey
    
    public convenience init(P8String: String) throws {
        let keyString = P8String.components(separatedBy: "\n").filter({ !$0.hasPrefix("-----") }).joined()
        guard
            let data = Data(base64Encoded: keyString) else {
                throw Error.failedBase64Encoding
        }
        try self.init(P8DERData: data)
    }
    
    public init(P8DERData: Data) throws {
        let (result, _) = ASN1.toElement(data: P8DERData)
        guard
            case let ASN1.Element.seq(elements: es) = result, es.count > 2,
            case let ASN1.Element.seq(elements: ids) = es[1], ids.count > 1,
            case let ASN1.Element.bytes(data: privateKeyID) = ids[1] else {
                throw Error.failedASN1Decoding
        }
        guard
            [UInt8](privateKeyID) == [0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07] else {
                throw Error.unsupportedCurve
        }
        guard
            case let ASN1.Element.bytes(data: privateOctest) = es[2] else {
                throw Error.failedASN1Decoding
        }
        let (octest, _) = ASN1.toElement(data: privateOctest)
        guard
            case let ASN1.Element.seq(elements: seq) = octest, seq.count >= 3,
            case let ASN1.Element.bytes(data: privateKeyData) = seq[1] else {
                throw Error.failedASN1Decoding
        }
        let publicKeyData: Data
        if
            case let ASN1.Element.constructed(tag: 1, elem: publicElement) = seq[2],
            case let ASN1.Element.bytes(data: pubKeyData) = publicElement {
            publicKeyData = pubKeyData
        } else if
            seq.count >= 4,
            case let ASN1.Element.constructed(tag: 1, elem: publicElement) = seq[3],
            case let ASN1.Element.bytes(data: pubKeyData) = publicElement {
            publicKeyData = pubKeyData
        } else {
            throw Error.failedASN1Decoding
        }
        
        let trimmedPubBytes = publicKeyData.drop(while: { $0 == 0x00})
        
        let keyData = trimmedPubBytes + privateKeyData
        var error: Unmanaged<CFError>? = nil
        let attributes: CFDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary
        guard
            let secKey = SecKeyCreateWithData(keyData as CFData, attributes, &error) else {
                if let secError = error?.takeRetainedValue() {
                    throw secError
                } else {
                    throw Error.failedNativeKeyCreation
                }
        }
        self.secKey = secKey
    }
    
    public func sign(data: Data) throws -> Data {
        
        let hash: Data = {
            var reval = [UInt8](repeating: 0, count: Int(CC_LONG(CC_SHA256_DIGEST_LENGTH)))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &reval)
            }
            return Data(reval)
        }()
        
        var error: Unmanaged<CFError>? = nil
        guard
            let signature = SecKeyCreateSignature(self.secKey, .ecdsaSignatureDigestX962SHA256, hash as CFData, &error) else {
                if let thrownError = error?.takeRetainedValue() {
                    throw thrownError
                } else {
                    throw Error.failedSigningAlgorithm
                }
        }
        
        let asn1 = signature as Data
        
        let signatureLength: Int
        if asn1.count < 96 {
            signatureLength = 64
        } else if asn1.count < 132 {
            signatureLength = 96
        } else {
            signatureLength = 132
        }
        
        let (asnSig, _) = ASN1.toElement(data: asn1)
        guard
            case let ASN1.Element.seq(elements: seq) = asnSig, seq.count >= 2,
            case let ASN1.Element.bytes(data: rData) = seq[0],
            case let ASN1.Element.bytes(data: sData) = seq[1] else {
                throw Error.failedASN1Decoding
        }
        let trimmedRData: Data
        let trimmedSData: Data
        let rExtra = rData.count - signatureLength / 2
        if rExtra < 0 {
            trimmedRData = Data(count: 1) + rData
        } else {
            trimmedRData = rData.dropFirst(rExtra)
        }
        let sExtra = sData.count - signatureLength / 2
        if sExtra < 0 {
            trimmedSData = Data(count: 1) + sData
        } else {
            trimmedSData = sData.dropFirst(sExtra)
        }
        return trimmedRData + trimmedSData
    }
}

private struct ASN1 {
    
    indirect enum Element {
        case seq(elements: [Element])
        case integer(int: Int)
        case bytes(data: Data)
        case constructed(tag: Int, elem: Element)
        case unknown
    }
    
    static func toElement(data: Data) -> (Element, Int) {
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
                let (e, l) = toElement(data: subdata)
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
            let (e, _) = toElement(data: subdata)
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

