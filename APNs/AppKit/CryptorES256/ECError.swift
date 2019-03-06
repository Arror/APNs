import Foundation

public struct ECError: Error, Equatable {
    
    public let localizedDescription: String

    private let internalError: InternalError
    
    private enum InternalError {
        case invalidPEMString, unknownPEMHeader, failedBase64Encoding, failedASN1Decoding, unsupportedCurve, failedNativeKeyCreation, failedEvpInit, failedSigningAlgorithm, invalidRSLength, failedEncryptionAlgorithm, failedUTF8Decoding, failedDecryptionAlgorithm
    }
    
    public static let invalidPEMString = ECError(localizedDescription: "Input was not a valid PEM String", internalError: .invalidPEMString)
    
    public static let unknownPEMHeader = ECError(localizedDescription: "Input PEM header was not recognized", internalError: .unknownPEMHeader)

    public static let failedBase64Encoding = ECError(localizedDescription: "Failed to base64 encode the String", internalError: .failedBase64Encoding)

    public static let failedASN1Decoding = ECError(localizedDescription: "ASN1 data could not be decoded to expected structure", internalError: .failedASN1Decoding)
    
    public static let unsupportedCurve = ECError(localizedDescription: "The key object identifier is for a non-supported curve", internalError: .unsupportedCurve)
    
    public static let failedNativeKeyCreation = ECError(localizedDescription: "The key data could not be converted to a native key", internalError: .failedNativeKeyCreation)
    
    public static let failedEvpInit = ECError(localizedDescription: "Failed to initialize the signing envelope", internalError: .failedEvpInit)
        
    public static let failedSigningAlgorithm = ECError(localizedDescription: "Signing algorithm failed to create the signature", internalError: .failedSigningAlgorithm)
    
    public static let invalidRSLength = ECError(localizedDescription: "The provided R and S values were not a valid length", internalError: .invalidRSLength)
    
    public static let failedEncryptionAlgorithm = ECError(localizedDescription: "Encryption algorithm failed to encrypt the data", internalError: .failedEncryptionAlgorithm)
    
    public static let failedDecryptionAlgorithm = ECError(localizedDescription: "Decryption algorithm failed to decrypt the data", internalError: .failedDecryptionAlgorithm)
    
    public static let failedUTF8Decoding = ECError(localizedDescription: "Data could not be decoded as a UTF8 String", internalError: .failedUTF8Decoding)
    
    public static func == (lhs: ECError, rhs: ECError) -> Bool {
        return lhs.internalError == rhs.internalError
    }
}
