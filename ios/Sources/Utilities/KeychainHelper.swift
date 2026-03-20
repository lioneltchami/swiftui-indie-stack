//
//  KeychainHelper.swift
//  MyApp
//
//  Generic Keychain wrapper using Security framework.
//  Provides save/read/delete operations for sensitive data storage
//  with migration support from UserDefaults.
//

import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case duplicateItem
    case itemNotFound
    case unexpectedStatus(OSStatus)
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .duplicateItem: return "Keychain item already exists"
        case .itemNotFound: return "Keychain item not found"
        case .unexpectedStatus(let status): return "Keychain error: \(status)"
        case .encodingError: return "Failed to encode data for Keychain"
        case .decodingError: return "Failed to decode data from Keychain"
        }
    }
}

struct KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    private let service = Bundle.main.bundleIdentifier ?? "com.myapp"

    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func save(_ string: String, forKey key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(data, forKey: key)
    }

    func read(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    func readString(forKey key: String) -> String? {
        guard let data = read(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Migrate a value from UserDefaults to Keychain (one-time migration)
    func migrateFromUserDefaults(key: String) {
        if let existingValue = UserDefaults.standard.string(forKey: key) {
            try? save(existingValue, forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
