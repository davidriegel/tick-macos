//
//  AppDelegate.swift
//  Tick
//
//  Created by David Riegel on 02.08.26.
//

import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppSettings.shared.applyActivationPolicy()

        #if DEBUG
        ScreenshotExporter.runIfLaunchedForExport()
        #endif
    }
}
