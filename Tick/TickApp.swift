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
        WindowGroup {
            TokenListView()
                .environment(tokenStore)
        }
    }
}
