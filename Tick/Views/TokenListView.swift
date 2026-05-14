//
//  TokenListView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenListView: View {
    @Environment(TokenStore.self) private var tokenStore
    @State private var showingAdd = false
    @State private var tokenToDelete: OTPToken?
    @State private var migrationResult: MigrationResult?
    
    struct MigrationResult: Identifiable {
        let id = UUID()
        let added: Int
        let skipped: Int
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if tokenStore.tokens.isEmpty {
                    emptyState
                } else {
                    tokenList
                }
            }
            .toolbar {
                Button("Add token", systemImage: "plus") {
                    showingAdd = true
                }
                .keyboardShortcut(KeyboardShortcut(KeyEquivalent("n")))
                .sheet(isPresented: $showingAdd) {
                    AddTokenView { token in
                        tokenStore.add(token)
                        showingAdd = false
                    } onBulkInsert: { tokens in
                        let added = tokenStore.addBulk(tokens)
                        let skipped = tokens.count - added
                        showingAdd = false
                        migrationResult = MigrationResult(added: added, skipped: skipped)
                    } onCancel: {
                        showingAdd = false
                    }
                }
            }
        }
        .alert(
            "Import Complete",
            isPresented: .init(
                get: { migrationResult != nil },
                set: { if !$0 { migrationResult = nil } }
            ),
            presenting: migrationResult
        ) { _ in
            Button("OK") {}
        } message: { result in
            if result.skipped == 0 {
                Text("\(result.added) token\(result.added == 1 ? "" : "s") imported.")
            } else {
                Text("\(result.added) imported, \(result.skipped) duplicate\(result.skipped == 1 ? "" : "s") skipped.")
            }
        }
        .confirmationDialog(
            "Delete Token?",
            isPresented: .init(
                get: { tokenToDelete != nil },
                set: { if !$0 { tokenToDelete = nil } }
            ),
            presenting: tokenToDelete
        ) { token in
            Button("Delete \(token.issuer)", role: .destructive) {
                tokenStore.remove(token)
            }
            Button("Cancel", role: .cancel) {}
        } message: { token in
            Text("This will permanently remove the TOTP for \(token.issuer) (\(token.account)). You can't undo this.")
        }
    }
    
    // MARK: - TokenList
    
    var tokenList: some View {
        List(tokenStore.tokens) { token in
            TokenRowView(token: token)
                .contextMenu {
                    Button("Copy Code") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(TOTPGenerator.generate(for: token), forType: .string)
                    }
                    
                    Button("Copy Account") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(token.account, forType: .string)
                    }
                    
                    Divider()
                    
                    Button("Delete", role: .destructive) {
                        tokenToDelete = token
                    }
                }
        }
    }
    
    // MARK: - Empty State
    
    var emptyState: some View {
        ContentUnavailableView(
            "No tokens added",
            systemImage: "lock.shield",
            description: Text("Add a new one with ⌘N")
        )
    }
}

#Preview() {
    TokenListView()
        .environment(TokenStore())
}
