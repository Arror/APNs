import Foundation

struct KeychainDataItem {
    
    enum KeychainError: CustomNSError {

        case noData        
        case unexpectedData
        case unexpectedItem
        case unhandledError(status: OSStatus)        
        
        var errorCode: Int {
            switch self {
            case .noData:
                return 1
            case .unexpectedData:
                return 2
            case .unexpectedItem:
                return 3
            case let .unhandledError(status):
                return Int(status)
            }
        }
        
        var errorUserInfo: [String : Any] {   
            let desp: String
            switch self {
            case .noData:
                desp = "No such Data."
            case .unexpectedData:
                desp = "Unexpected Data."
            case .unexpectedItem:
                desp = "Unexpected Item"
            case let .unhandledError(status):
                if #available(iOS 11.3, *) {
                    if let message = SecCopyErrorMessageString(status, nil) as String? {
                        desp = message
                    } else {
                        desp = "Keychain data item error."
                    }
                } else {
                    desp = "Keychain data item error."
                }
            }
            return [NSLocalizedDescriptionKey: desp]
        }
        
    }

    let service: String
    private(set) var account: String    
    let accessGroup: String?
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
        
    func readData() throws -> Data  {
        
        var query = KeychainDataItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noData
        }
        guard status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard
            let existingItem = queryResult as? [String : Any],
            let data = existingItem[kSecValueData as String] as? Data else {
                throw KeychainError.unexpectedData
        }
        
        return data
    }
    
    func saveData(_ data: Data) throws {
        do {
            try _ = readData()

            var attributesToUpdate = [String : Any]()
            attributesToUpdate[kSecValueData as String] = data

            let query = KeychainDataItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        }
        catch KeychainError.noData {
            var newItem = KeychainDataItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = data
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    mutating func renameAccount(_ newAccountName: String) throws {
        
        var attributesToUpdate = [String : Any]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName
        
        let query = KeychainDataItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {
        
        let query = KeychainDataItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    static func items(forService service: String, accessGroup: String? = nil) throws -> [KeychainDataItem] {
        
        var query = KeychainDataItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        guard status != errSecItemNotFound else {
            return []
        }

        guard status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let resultData = queryResult as? [[String : AnyObject]] else {
            throw KeychainError.unexpectedItem
        }

        var passwordItems = [KeychainDataItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else {
                throw KeychainError.unexpectedItem
            }
            let passwordItem = KeychainDataItem(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }

        return passwordItems
    }
    
    static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : Any] {
        var query = [String : Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        query[kSecAttrAccount as String] = account
        query[kSecAttrAccessGroup as String] = accessGroup
        return query
    }
}
