//
//  KeychainService.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation
import Security

final class KeychainService {
    private let service = "com.davidriegel.Tick"
    
    func save(_ token: OTPToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: token.id.uuidString,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func loadAll() -> [OTPToken] {
        let attributesQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue!
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
                kSecReturnData as String: kCFBooleanTrue!
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
            kSecAttrAccount as String: id.uuidString
        ]
        SecItemDelete(query as CFDictionary)
    }
}
