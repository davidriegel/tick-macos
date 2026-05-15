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
    
    private var tokenList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
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
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No tokens yet")
                .font(.headline)
            Text("Add one in the main window")
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
                Label("Open Tick", systemImage: "macwindow")
            }
            .buttonStyle(.borderless)
            
            Spacer()
            
            Button {
                NSApp.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
