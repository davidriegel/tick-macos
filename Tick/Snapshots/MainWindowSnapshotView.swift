//
//  MainWindowSnapshotView.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

#if DEBUG
import SwiftUI

struct MainWindowSnapshotView: View {
    var entries: [DemoEntry] = DemoEntry.showcase
    var size: CGSize = TokenListView.windowSize
    var includesShadow: Bool = true

    private let listInset: CGFloat = 10
    private let rowInset: CGFloat = 10

    var body: some View {
        SnapshotWindow(title: "Tick", size: size, includesShadow: includesShadow) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .medium))
        } content: {
            tokenList
        }
    }

    private var tokenList: some View {
        VStack(spacing: 0) {
            ForEach(entries) { entry in
                TokenRowContent(presentation: entry.presentation, accent: .brandAccent)
                    .padding(.horizontal, rowInset)

                if entry.id != entries.last?.id {
                    Divider()
                        .padding(.leading, rowInset)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, listInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

#Preview {
    MainWindowSnapshotView()
}
#endif
