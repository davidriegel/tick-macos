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
                    } onCancel: {
                        showingAdd = false
                    }
                }
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
