import Foundation
import CommonCrypto

@available(OSX 10.13, *)
public struct ES256Signature {
    
    public let r: Data
    public let s: Data
    public let asn1: Data
    
    public init(r: Data, s: Data) throws {
        let asn1 = try ES256Signature.rsSigToASN1(r: r, s: s)
        self.r = r
        self.s = s
        self.asn1 = asn1
    }
    
    public init(asn1: Data) throws {
        self.asn1 = asn1
        let (r,s) = try ES256Signature.asn1ToRSSig(asn1: asn1)
        self.r = r
        self.s = s
    }
    
    static func rsSigToASN1(r: Data, s: Data) throws -> Data {
        
        guard r.count == s.count, r.count == 32 || r.count == 48 || r.count == 66 else {
            throw ECError.invalidRSLength
        }
        var asnSignature = Data()
        var rSig =  r
        if rSig[0] == 0 {
            rSig = rSig.advanced(by: 1)
        }
        if rSig[0].leadingZeroBitCount == 0 {
            rSig = Data(count: 1) + rSig
        }
        var sSig = s
        if sSig[0] == 0 {
            sSig = sSig.advanced(by: 1)
        }
        if sSig[0].leadingZeroBitCount == 0 {
            sSig = Data(count: 1) + sSig
        }
        let rLengthByte = UInt8(rSig.count)
        let sLengthByte = UInt8(sSig.count)
        let tLengthByte = rLengthByte + sLengthByte + 4
        if tLengthByte > 127 {
            asnSignature.append(contentsOf: [0x30, 0x81, tLengthByte])
        } else {
            asnSignature.append(contentsOf: [0x30, tLengthByte])
        }
        asnSignature.append(contentsOf: [0x02, rLengthByte])
        asnSignature.append(rSig)
        asnSignature.append(contentsOf: [0x02, sLengthByte])
        asnSignature.append(sSig)
        return asnSignature
    }

    static func asn1ToRSSig(asn1: Data) throws -> (Data, Data) {
        
        let signatureLength: Int
        if asn1.count < 96 {
            signatureLength = 64
        } else if asn1.count < 132 {
            signatureLength = 96
        } else {
            signatureLength = 132
        }
        
        let (asnSig, _) = ASN1.toASN1Element(data: asn1)
        guard case let ASN1.ASN1Element.seq(elements: seq) = asnSig,
            seq.count >= 2,
            case let ASN1.ASN1Element.bytes(data: rData) = seq[0],
            case let ASN1.ASN1Element.bytes(data: sData) = seq[1]
        else {
            throw ECError.failedASN1Decoding
        }
        let trimmedRData: Data
        let trimmedSData: Data
        let rExtra = rData.count - signatureLength/2
        if rExtra < 0 {
            trimmedRData = Data(count: 1) + rData
        } else {
            trimmedRData = rData.dropFirst(rExtra)
        }
        let sExtra = sData.count - signatureLength/2
        if sExtra < 0 {
            trimmedSData = Data(count: 1) + sData
        } else {
            trimmedSData = sData.dropFirst(sExtra)
        }
        return (trimmedRData, trimmedSData)
    }
}
