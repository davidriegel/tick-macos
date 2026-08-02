//
//  TickApp.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

@main
struct TickApp: App {
    @State private var tokenStore = TokenStore()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Tick", id: "main") {
            TokenListView()
                .environment(tokenStore)
                .environment(AppSettings.shared)
                .frame(
                    minWidth: TokenListView.windowSize.width,
                    minHeight: TokenListView.windowSize.height
                )
        }
        .defaultSize(TokenListView.windowSize)
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .commands {
        #if DEBUG
            CommandMenu("Screenshots") {
                Button("Alle exportieren") {
                    ScreenshotExporter.exportAll()
                }
                .keyboardShortcut("e", modifiers: [.command, .option, .shift])

                Divider()

                ForEach(ScreenshotExporter.Asset.allCases) { asset in
                    Button("\(asset.title) exportieren") {
                        ScreenshotExporter.export(asset)
                    }
                }
            }
        #endif
        }

        Settings {
            SettingsView()
                .environment(AppSettings.shared)
        }

        MenuBarExtra("Tick", systemImage: "lock.shield.fill") {
            MenuBarView()
                .environment(tokenStore)
                .environment(AppSettings.shared)
        }
        .menuBarExtraStyle(.window)
    }
}
