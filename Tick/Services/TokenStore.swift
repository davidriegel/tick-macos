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
        guard !contains(token) else { return }
        tokens.append(token)
        keychain.save(token)
    }
    
    public func remove(_ token: OTPToken) {
        tokens.removeAll { $0.id == token.id }
        keychain.delete(id: token.id)
    }
    
    @discardableResult
    public func addBulk(_ newTokens: [OTPToken]) -> Int {
        var addedCount = 0
        for token in newTokens {
            guard !contains(token) else { continue }
            tokens.append(token)
            keychain.save(token)
            addedCount += 1
        }
        return addedCount
    }
    
    public func update(_ token: OTPToken) {
        guard let index = tokens.firstIndex(where: { $0.id == token.id }) else { return }
        tokens[index] = token
        keychain.save(token)
    }
    
    // MARK: - Private
    
    private func load() {
        tokens = keychain.loadAll()
    }
    
    private func contains(_ token: OTPToken) -> Bool {
        tokens.contains { existing in
            existing.secret == token.secret &&
            existing.issuer == token.issuer &&
            existing.account == token.account
        }
    }
}
