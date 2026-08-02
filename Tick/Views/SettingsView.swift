//
//  SettingsView.swift
//  Tick
//
//  Created by David Riegel on 21.05.26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                Toggle(isOn: $settings.startsAtLogin) {
                    Text(.settingsviewStartOnLaunch)
                }

                if settings.loginItemNeedsApproval {
                    HStack(alignment: .firstTextBaseline) {
                        Text(.settingsviewLoginApprovalHint)
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(.settingsviewOpenLoginItems) {
                            settings.openLoginItemSettings()
                        }
                    }
                }

                if settings.loginItemFailed {
                    Text(.settingsviewLoginItemFailed)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                Toggle(isOn: $settings.showsDockIcon) {
                    Text(.settingsviewShowDockIcon)
                }
            } header: {
                Text(.settingsviewSectionGeneral)
            }

            Section {
                Toggle(isOn: $settings.hidesCodes) {
                    Text(.settingsviewHideCodes)
                }
            } header: {
                Text(.settingsviewSectionPrivacy)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .navigationTitle(Text(.settingsviewTitle))
        .onAppear {
            settings.refreshLoginItemStatus()
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings.shared)
}
