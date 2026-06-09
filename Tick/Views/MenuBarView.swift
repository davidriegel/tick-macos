//
//  MenuBarView.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//


import SwiftUI

struct MenuBarView: View {
    @Environment(TokenStore.self) private var tokenStore
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            if tokenStore.tokens.isEmpty {
                emptyState
            } else {
                tokenList
            }
            
            Divider()
            
            footer
        }
        .frame(width: 320)
        .frame(maxHeight: 480)
    }
    
    // MARK: - Token List
    

    // For smaller token counts, render the VStack directly to ensure natural sizing.
    // If the token count exceeds scrollThreshold, wrap tokenListContent in ScrollView with scrolledHeight.
    private static let scrollThreshold = 7
    private static let scrolledHeight: CGFloat = 420

    @ViewBuilder
    private var tokenList: some View {
        if tokenStore.tokens.count > Self.scrollThreshold {
            ScrollView {
                tokenListContent
            }
            .frame(height: Self.scrolledHeight)
        } else {
            tokenListContent
        }
    }

    private var tokenListContent: some View {
        VStack(spacing: 0) {
            ForEach(tokenStore.tokens) { token in
                TokenRowView(token: token)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)

                if token.id != tokenStore.tokens.last?.id {
                    Divider()
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(.menubarviewNotokens)
                .font(.headline)
            Text(.menubarviewAddtokens)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Button {
                openWindow(id: "main")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    guard let window = NSApp.windows.first(where: { $0.title == "Tick" }) else { return }
                    
                    window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
                    
                    NSApp.activate(ignoringOtherApps: true)
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                }
            } label: {
                Label(.menubarviewOpen, systemImage: "macwindow")
            }
            .buttonStyle(.borderless)
            
            Spacer()
            
            Button {
                NSApp.terminate(nil)
            } label: {
                Label(.menubarviewQuit, systemImage: "power")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
