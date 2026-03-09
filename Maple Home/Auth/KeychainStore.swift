import Foundation
import Security

// MARK: - KeychainStore

enum KeychainStore {
    private static let serviceName = "com.maple.home"

    static func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func clearAll() {
        let keys = [Keys.serverURL, Keys.accessToken, Keys.refreshToken, Keys.tokenExpiry]
        for key in keys {
            delete(key: key)
        }
    }

    // MARK: - Keys

    enum Keys {
        static let serverURL = "maple.server_url"
        static let accessToken = "maple.access_token"
        static let refreshToken = "maple.refresh_token"
        static let tokenExpiry = "maple.token_expiry"
    }
}

// MARK: - Keychain Error

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed
}
