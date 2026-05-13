//
//  TokenListView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenListView: View {
    let tokenStore = TokenStore()
    
    var body: some View {
        List(tokenStore.tokens) { token in
            TokenRowView(token: token)
        }
    }
}

#Preview {
    TokenListView()
}
