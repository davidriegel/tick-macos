//
//  ScreenshotExporter.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

#if DEBUG
import SwiftUI
import AppKit

enum ScreenshotExporter {

    nonisolated static let defaultScale: CGFloat = 6

    // MARK: - Assets

    enum Asset: String, CaseIterable, Identifiable {
        case menuBar = "menubar"
        case mainWindow = "mainwindow"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .menuBar: "Menu Bar Popover"
            case .mainWindow: "Hauptfenster"
            }
        }

        @MainActor
        @ViewBuilder
        var view: some View {
            switch self {
            case .menuBar: MenuBarSnapshotView()
            case .mainWindow: MainWindowSnapshotView()
            }
        }
    }

    static var languages: [String] {
        Bundle.main.localizations
            .filter { $0 != "Base" }
            .sorted()
    }

    static var directory: URL {
        URL.documentsDirectory.appending(path: "Tick Screenshots")
    }

    // MARK: - Export

    @MainActor
    @discardableResult
    static func exportAll(scale: CGFloat = defaultScale, reveal shouldReveal: Bool = true) -> [URL] {
        let written = Asset.allCases.flatMap { export($0, scale: scale, reveal: false) }
        if shouldReveal { reveal(written) }
        return written
    }

    @MainActor
    @discardableResult
    static func export(
        _ asset: Asset,
        scale: CGFloat = defaultScale,
        reveal shouldReveal: Bool = true
    ) -> [URL] {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        var written: [URL] = []

        for language in languages {
            for scheme in [ColorScheme.light, .dark] {
                let name = [
                    asset.rawValue,
                    language,
                    scheme == .light ? "light" : "dark"
                ].joined(separator: "-") + "@\(Int(scale))x.png"

                let view = asset.view
                    .environment(\.colorScheme, scheme)
                    .environment(\.locale, Locale(identifier: language))

                guard let data = png(from: view, scale: scale) else {
                    print("⚠️ \(name): Rendering fehlgeschlagen")
                    continue
                }

                let url = directory.appending(path: name)

                do {
                    try data.write(to: url)
                    written.append(url)
                    print("✅ \(name) – \(data.count / 1024) KB")
                } catch {
                    print("⚠️ \(name): Schreiben fehlgeschlagen – \(error)")
                }
            }
        }

        if shouldReveal { reveal(written) }
        return written
    }

    // MARK: - Rendering

    @MainActor
    static func png(from view: some View, scale: CGFloat) -> Data? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        renderer.isOpaque = false

        guard let cgImage = renderer.cgImage else { return nil }

        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.size = NSSize(width: cgImage.width, height: cgImage.height)
        return rep.representation(using: .png, properties: [:])
    }

    @MainActor
    private static func reveal(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    // MARK: - Launch Argument

    static let launchArgument = "-export-screenshots"

    @MainActor
    static func runIfLaunchedForExport() {
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else { return }

        let written = exportAll(reveal: false)
        print("📸 \(written.count) Screenshots in \(directory.path(percentEncoded: false))")
        NSApp.terminate(nil)
    }
}

@MainActor
final class ScreenshotLaunchDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        ScreenshotExporter.runIfLaunchedForExport()
    }
}
#endif
