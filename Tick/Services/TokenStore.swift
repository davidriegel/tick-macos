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
        load()
    }
    
    // MARK: - Public
    
    public func add(_ token: OTPToken) {
        tokens.append(token)
        keychain.save(token)
    }
    
    public func remove(_ token: OTPToken) {
        tokens.removeAll { $0.id == token.id }
        keychain.delete(id: token.id)
    }
    
    // MARK: - Private
    
    private func load() {
        tokens = keychain.loadAll()
    }
}
