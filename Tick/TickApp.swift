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

    #if DEBUG
    @NSApplicationDelegateAdaptor(ScreenshotLaunchDelegate.self) private var screenshotDelegate
    #endif

    var body: some Scene {
        Window("Tick", id: "main") {
            TokenListView()
                .environment(tokenStore)
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

        MenuBarExtra("Tick", systemImage: "lock.shield.fill") {
            MenuBarView()
                .environment(tokenStore)
        }
        .menuBarExtraStyle(.window)
    }
}
