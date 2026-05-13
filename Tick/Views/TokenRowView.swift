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
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let otpCode = TOTPGenerator.generate(for: token, at: context.date)
            let otpProgress = TOTPGenerator.progress(for: token, at: context.date)
            let otpSeconds = TOTPGenerator.secondsRemaining(for: token, at: context.date)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(token.issuer)
                        .font(.headline)
                    Text(token.account)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(formatCode(otpCode))
                    .font(.system(.title2,design: .monospaced, weight: .medium))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: otpCode)
                CircularProgressBarView(progress: otpProgress)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text("\(otpSeconds)")
                            .font(.caption2)
                            .monospacedDigit()
                    }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
    }
    
    private func formatCode(_ code: String) -> String {
        guard code.count == 6 else { return code }
        let middleIndex = code.index(code.startIndex, offsetBy: 3)
        return "\(code[..<middleIndex]) \(code[middleIndex...])"
    }
}

#Preview {
    TokenRowView(token: OTPToken(issuer: "Github", account: "davidriegel", secret: Data()))
}
