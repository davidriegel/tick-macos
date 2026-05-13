//
//  TokenRowView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenRowView: View {
    let token: OTPToken
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(token.issuer)
                    .font(.headline)
                Text(token.account)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("123 456")
                .font(.system(.title2,design: .monospaced, weight: .medium))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: "123 456")
            CircularProgressBarView(progress: 0.25)
                .frame(width: 32, height: 32)
                .overlay {
                    Text("10")
                        .font(.caption2)
                        .monospacedDigit()
                }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    TokenRowView(token: OTPToken(issuer: "Github", account: "davidriegel", secret: Data()))
}
