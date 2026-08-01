//
//  SettingsView.swift
//  Tick
//
//  Created by David Riegel on 21.05.26.
//

import SwiftUI

struct SettingsView: View {
    @State private var startOnLaunch: Bool = true
    var body: some View {
        Text(.settingsviewTitle)
            .font(.headline)
        VStack(spacing: 20) {
            Toggle(isOn: $startOnLaunch) {
                Text(.settingsviewStartOnLaunch)
            }
            .toggleStyle(.switch)
        }
    }
}

#Preview {
    SettingsView()
}
