//
//  TokenListView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenListView: View {
    @Environment(TokenStore.self) private var tokenStore
    
    var body: some View {
        NavigationStack {
            Group {
                if tokenStore.tokens.isEmpty {
                    emptyState
                } else {
                    tokenList
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
            Text("No tokens saved")
                .font(.title)
                .fontWeight(.semibold)
            Button("Add token", systemImage: "plus") {
                
            }
        }
    }
}

#Preview("Empty state") {
    TokenListView()
        .frame(minWidth: 300, minHeight: 500)
        .environment(TokenStore())
}
