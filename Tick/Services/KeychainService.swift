//
//  KeychainService.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation
import Security

final class KeychainService {
    private let service = "com.davidriegel.tick"
    
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
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let dataArray = result as? [Data] else { return [] }
        return dataArray.compactMap { try? JSONDecoder().decode(OTPToken.self, from: $0) }
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
