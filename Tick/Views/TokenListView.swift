//
//  TokenListView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenListView: View {
    var body: some View {
        List() {
            TokenRowView(token: OTPToken(issuer: "Github", account: "davidriegel", secret: Data()))
        }
    }
}

#Preview {
    TokenListView()
}
