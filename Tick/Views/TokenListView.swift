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
    }
    
    // MARK: - TokenList
    
    var tokenList: some View {
        List(tokenStore.tokens) { token in
            TokenRowView(token: token)
        }
    }
    
    // MARK: - Empty State
    
    var emptyState: some View {
        VStack {
            ContentUnavailableView(
                "No tokens added",
                systemImage: "lock.shield",
                description: Text("Add a new one with ⌘N")
            )
        }
    }
}

#Preview() {
    TokenListView()
        .environment(TokenStore())
}
