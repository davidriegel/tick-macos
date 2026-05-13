//
//  TokenStore.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation

@Observable
final class TokenStore {
    
    // MARK: - Config
    private(set) var tokens: [OTPToken] = []
    private let keychain = KeychainService()
    
    
    // MARK: - Initializer
    init() {
        
    }
    
}
