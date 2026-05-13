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
                .frame(minWidth: 300, idealWidth: 300, minHeight: 500, idealHeight: 500)
                .environment(tokenStore)
        }
    }
}
