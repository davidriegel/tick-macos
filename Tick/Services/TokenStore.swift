//
//  TokenStore.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation
import SwiftUI

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
        var newToken = token
        newToken.sortIndex = nextSortIndex()
        tokens.append(newToken)
        keychain.save(newToken)
    }
    
    @discardableResult
    public func addBulk(_ newTokens: [OTPToken]) -> Int {
        var addedCount = 0
        var nextIndex = nextSortIndex()
        
        for token in newTokens {
            guard !contains(token) else { continue }
            var newToken = token
            newToken.sortIndex = nextIndex
            tokens.append(newToken)
            keychain.save(newToken)
            nextIndex += 1
            addedCount += 1
        }
        return addedCount
    }
    
    public func update(_ token: OTPToken) {
        guard let index = tokens.firstIndex(where: { $0.id == token.id }) else { return }
        tokens[index] = token
        keychain.save(token)
    }
    
    public func reorder(fromOffsets source: IndexSet, toOffset destination: Int) {
        tokens.move(fromOffsets: source, toOffset: destination)
        
        for i in tokens.indices {
            tokens[i].sortIndex = i
            keychain.save(tokens[i])
        }
    }
    
    public func remove(_ token: OTPToken) {
        tokens.removeAll { $0.id == token.id }
        keychain.delete(id: token.id)
    }
    
    // MARK: - Private
    
    private func nextSortIndex() -> Int {
        (tokens.map(\.sortIndex).max() ?? -1) + 1
    }
    
    private func contains(_ token: OTPToken) -> Bool {
        tokens.contains { existing in
            existing.secret == token.secret &&
            existing.issuer == token.issuer &&
            existing.account == token.account
        }
    }
    
    private func load() {
        tokens = keychain.loadAll().sorted { $0.sortIndex < $1.sortIndex }
    }
}
