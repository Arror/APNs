import Foundation
import CommonCrypto

@available(OSX 10.13, *)
public class ES256PrivateKey {

    let secKey: SecKey
    let pubKeyBytes: Data
    
    public convenience init(key: String) throws {
        let strippedKey = String(key.filter { !" \n\t\r".contains($0) })
        var pemComponents = strippedKey.components(separatedBy: "-----")
        guard pemComponents.count >= 5 else {
            throw ECError.invalidPEMString
        }
        guard let der = Data(base64Encoded: pemComponents[2]) else {
            throw ECError.failedBase64Encoding
        }
        try self.init(pkcs8DER: der)
    }
    
    public init(pkcs8DER: Data) throws {
        let (result, _) = ASN1.toASN1Element(data: pkcs8DER)
        guard
            case let ASN1.ASN1Element.seq(elements: es) = result, es.count > 2,
            case let ASN1.ASN1Element.seq(elements: ids) = es[1], ids.count > 1,
            case let ASN1.ASN1Element.bytes(data: privateKeyID) = ids[1] else {
                throw ECError.failedASN1Decoding
        }
        guard
            [UInt8](privateKeyID) == [0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07] else {
                throw ECError.unsupportedCurve
        }
        guard
            case let ASN1.ASN1Element.bytes(data: privateOctest) = es[2] else {
                throw ECError.failedASN1Decoding
        }
        let (octest, _) = ASN1.toASN1Element(data: privateOctest)
        guard
            case let ASN1.ASN1Element.seq(elements: seq) = octest, seq.count >= 3,
            case let ASN1.ASN1Element.bytes(data: privateKeyData) = seq[1] else {
                throw ECError.failedASN1Decoding
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
            throw ECError.failedASN1Decoding
        }
        let trimmedPubBytes = publicKeyData.drop(while: { $0 == 0x00})
        self.secKey =  try ES256PrivateKey.bytesToNativeKey(privateKeyData: privateKeyData,
                                                            publicKeyData: trimmedPubBytes)
        self.pubKeyBytes = trimmedPubBytes
    }
    
    private static func bytesToNativeKey(privateKeyData: Data, publicKeyData: Data) throws -> SecKey {
        let keyData = publicKeyData + privateKeyData
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
                    throw ECError.failedNativeKeyCreation
                }
        }
        return secKey
    }
}
