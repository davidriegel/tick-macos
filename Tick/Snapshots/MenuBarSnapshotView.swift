//
//  MenuBarSnapshotView.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

#if DEBUG
import SwiftUI

struct MenuBarSnapshotView: View {
    var entries: [DemoEntry] = DemoEntry.showcase
    var includesShadow: Bool = true

    var body: some View {
        MenuBarContent {
            MenuBarTokenList(items: entries) { entry in
                TokenRowContent(presentation: entry.presentation, accent: .brandAccent)
            }
        } footer: {
            MenuBarFooter()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .snapshotSurface(cornerRadius: 10, includesShadow: includesShadow)
    }
}

#Preview {
    MenuBarSnapshotView()
}
#endif
