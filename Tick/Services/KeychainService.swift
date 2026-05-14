//
//  KeychainService.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation
import Security

final class KeychainService {
    private let service: String
    
    init() {
        self.service = Bundle.main.bundleIdentifier ?? "com.davidriegel.Tick"
    }
    
    func save(_ token: OTPToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: token.id.uuidString,
            kSecUseDataProtectionKeychain as String: kCFBooleanTrue!
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if updateStatus == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            #if DEBUG
            if addStatus != errSecSuccess {
                print("Keychain add failed: \(addStatus)")
            }
            #endif
        } else if updateStatus != errSecSuccess {
            #if DEBUG
            print("Keychain update failed: \(updateStatus)")
            #endif
        }
    }
    
    func loadAll() -> [OTPToken] {
        let attributesQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecUseDataProtectionKeychain as String: kCFBooleanTrue!
        ]
        
        var attributesResult: AnyObject?
        let attributesStatus = SecItemCopyMatching(attributesQuery as CFDictionary, &attributesResult)
        
        guard attributesStatus == errSecSuccess,
              let items = attributesResult as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            guard let account = item[kSecAttrAccount as String] as? String else { return nil }
            
            let dataQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecUseDataProtectionKeychain as String: kCFBooleanTrue!
            ]
            
            var dataResult: AnyObject?
            let dataStatus = SecItemCopyMatching(dataQuery as CFDictionary, &dataResult)
            
            guard dataStatus == errSecSuccess,
                  let data = dataResult as? Data else {
                return nil
            }
            
            return try? JSONDecoder().decode(OTPToken.self, from: data)
        }
    }
    
    func delete(id: UUID) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id.uuidString,
            kSecUseDataProtectionKeychain as String: kCFBooleanTrue!
        ]
        SecItemDelete(query as CFDictionary)
    }
}
