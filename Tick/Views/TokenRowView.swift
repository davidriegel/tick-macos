//
//  TokenRowView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct TokenRowContent: View {
    let presentation: TokenPresentation
    var showsCopiedIndicator: Bool = false
    var hidesCode: Bool = false
    var accent: Color = .accentColor

    private var displayedCode: String {
        guard hidesCode else { return presentation.formattedCode }
        return String(presentation.formattedCode.map { $0 == " " ? " " : "•" })
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(presentation.issuer)
                    .font(.headline)
                Text(presentation.account)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(displayedCode)
                .font(.system(.title2, design: .monospaced, weight: .medium))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: presentation.code)

            ZStack {
                CircularProgressBarView(progress: presentation.progress, color: accent)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text("\(presentation.secondsRemaining)")
                            .font(.caption2)
                            .monospacedDigit()
                    }
                    .opacity(showsCopiedIndicator ? 0 : 1)

                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .opacity(showsCopiedIndicator ? 1 : 0)
            }
            .animation(.snappy, value: showsCopiedIndicator)
        }
        .padding(.vertical, 4)
    }
}

struct TokenRowView: View {
    let token: OTPToken

    @Environment(AppSettings.self) private var settings
    @State private var copied = false
    @State private var isHovered = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let presentation = TokenPresentation(token: token, at: context.date)

            TokenRowContent(
                presentation: presentation,
                showsCopiedIndicator: copied,
                hidesCode: settings.hidesCodes && !isHovered
            )
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
            .onTapGesture {
                copyCode(presentation.code)
            }
        }
    }

    private func copyCode(_ code: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)

        withAnimation(.snappy) {
            copied = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.snappy) {
                copied = false
            }
        }
    }
}

#Preview {
    TokenRowView(token: OTPToken(issuer: "Github", account: "davidriegel", secret: Data()))
        .environment(AppSettings.shared)
}
