//
//  AppSettings.swift
//  Tick
//
//  Created by David Riegel on 02.08.26.
//

import AppKit
import Observation
import ServiceManagement

@Observable
@MainActor
final class AppSettings {
    static let shared = AppSettings()

    var startsAtLogin: Bool {
        didSet {
            guard !isSyncing, startsAtLogin != oldValue else { return }
            applyLoginItem()
        }
    }

    var showsDockIcon: Bool {
        didSet {
            guard showsDockIcon != oldValue else { return }
            defaults.set(showsDockIcon, forKey: Key.showsDockIcon)
            applyActivationPolicy()
        }
    }

    var hidesCodes: Bool {
        didSet {
            guard hidesCodes != oldValue else { return }
            defaults.set(hidesCodes, forKey: Key.hidesCodes)
        }
    }

    private(set) var loginItemNeedsApproval = false
    private(set) var loginItemFailed = false

    private var isSyncing = false
    private let defaults = UserDefaults.standard

    private enum Key {
        static let showsDockIcon = "showsDockIcon"
        static let hidesCodes = "hidesCodes"
    }

    private init() {
        let defaults = UserDefaults.standard

        showsDockIcon = defaults.object(forKey: Key.showsDockIcon) as? Bool ?? Self.isRegularApp
        hidesCodes = defaults.bool(forKey: Key.hidesCodes)

        let status = SMAppService.mainApp.status
        startsAtLogin = status == .enabled || status == .requiresApproval
        loginItemNeedsApproval = status == .requiresApproval
    }

    // MARK: - Dock

    func applyActivationPolicy() {
        NSApp.setActivationPolicy(showsDockIcon ? .regular : .accessory)
    }

    private static var isRegularApp: Bool {
        Bundle.main.object(forInfoDictionaryKey: "LSUIElement") as? Bool != true
    }

    // MARK: - Login Item

    func refreshLoginItemStatus() {
        let status = SMAppService.mainApp.status

        isSyncing = true
        startsAtLogin = status == .enabled || status == .requiresApproval
        isSyncing = false

        loginItemNeedsApproval = status == .requiresApproval
    }

    func openLoginItemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }

    private func applyLoginItem() {
        do {
            if startsAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginItemFailed = false
        } catch {
            loginItemFailed = true
        }

        refreshLoginItemStatus()
    }
}
