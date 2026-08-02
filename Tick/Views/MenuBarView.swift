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
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        MenuBarContent {
            if tokenStore.tokens.isEmpty {
                MenuBarEmptyState()
            } else {
                MenuBarTokenList(items: tokenStore.tokens) { token in
                    TokenRowView(token: token)
                }
            }
        } footer: {
            MenuBarFooter(
                actions: .init(
                    open: openMainWindow,
                    settings: openSettingsWindow,
                    quit: { NSApp.terminate(nil) }
                )
            )
        }
    }

    private func openMainWindow() {
        openWindow(id: "main")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let window = NSApp.windows.first(where: { $0.title == "Tick" }) else { return }

            window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]

            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }

    private func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        openSettings()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let window = NSApp.windows.first(where: {
                $0.identifier?.rawValue.contains("Settings") == true
            }) else { return }

            window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]

            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }
}

// MARK: - Content

struct MenuBarContent<Content: View, Footer: View>: View {
    private let content: Content
    private let footer: Footer

    init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            content

            Divider()

            footer
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(width: 320)
        .frame(maxHeight: 480)
    }
}

// MARK: - Token List

struct MenuBarTokenList<Item: Identifiable, Row: View>: View {
    private let items: [Item]
    private let row: (Item) -> Row

    private static var scrollThreshold: Int { 7 }
    private static var scrolledHeight: CGFloat { 420 }

    init(items: [Item], @ViewBuilder row: @escaping (Item) -> Row) {
        self.items = items
        self.row = row
    }

    var body: some View {
        if items.count > Self.scrollThreshold {
            ScrollView {
                stack
            }
            .frame(height: Self.scrolledHeight)
        } else {
            stack
        }
    }

    private var stack: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                row(item)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)

                if item.id != items.last?.id {
                    Divider()
                }
            }
        }
    }
}

// MARK: - Footer

struct MenuBarFooter: View {
    struct Actions {
        let open: () -> Void
        let settings: () -> Void
        let quit: () -> Void
    }

    var actions: Actions?

    var body: some View {
        HStack(spacing: 12) {
            if let actions {
                Button(action: actions.open) { openLabel }
                    .buttonStyle(.borderless)
            } else {
                openLabel
            }

            Spacer()

            if let actions {
                Button(action: actions.settings) { settingsLabel }
                    .buttonStyle(.borderless)
                    .help(Text(.menubarviewSettings))
            } else {
                settingsLabel
            }

            if let actions {
                Button(action: actions.quit) { quitLabel }
                    .buttonStyle(.borderless)
                    .keyboardShortcut("q", modifiers: .command)
            } else {
                quitLabel
            }
        }
    }

    private var openLabel: some View {
        Label(.menubarviewOpen, systemImage: "macwindow")
    }

    private var settingsLabel: some View {
        Image(systemName: "gearshape")
    }

    private var quitLabel: some View {
        Label(.menubarviewQuit, systemImage: "power")
    }
}

// MARK: - Empty State

struct MenuBarEmptyState: View {
    var body: some View {
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
}
