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
    
    var body: some Scene {
        Window("Tick", id: "main") {
            TokenListView()
                .environment(tokenStore)
                .frame(minWidth: 480, minHeight: 600)
        }
        .defaultSize(width: 480, height: 600)
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        
        MenuBarExtra("Tick", systemImage: "lock.shield.fill") {
            MenuBarView()
                .environment(tokenStore)
        }
        .menuBarExtraStyle(.window)
    }
}
