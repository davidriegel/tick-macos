//
//  SnapshotChrome.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

#if DEBUG
import SwiftUI

// MARK: - Surface

private struct SnapshotSurface: ViewModifier {
    let cornerRadius: CGFloat
    let includesShadow: Bool

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
            }
            .shadow(
                color: .black.opacity(includesShadow ? 0.28 : 0),
                radius: includesShadow ? 14 : 0,
                y: includesShadow ? 6 : 0
            )
            .padding(includesShadow ? 32 : 0)
            .fixedSize()
    }
}

extension View {
    func snapshotSurface(cornerRadius: CGFloat, includesShadow: Bool) -> some View {
        modifier(SnapshotSurface(cornerRadius: cornerRadius, includesShadow: includesShadow))
    }
}

// MARK: - Window

struct SnapshotWindow<Toolbar: View, Content: View>: View {
    let title: String
    let size: CGSize
    var includesShadow: Bool = true

    private let toolbar: Toolbar
    private let content: Content

    private let titleBarHeight: CGFloat = 52
    private let trafficLightRed = Color(red: 1.00, green: 0.373, blue: 0.341)
    private let trafficLightYellow = Color(red: 0.996, green: 0.737, blue: 0.180)
    private let trafficLightGreen = Color(red: 0.157, green: 0.784, blue: 0.251)

    init(
        title: String,
        size: CGSize,
        includesShadow: Bool = true,
        @ViewBuilder toolbar: () -> Toolbar,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.size = size
        self.includesShadow = includesShadow
        self.toolbar = toolbar()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar

            Divider()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: size.width, height: size.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .snapshotSurface(cornerRadius: 12, includesShadow: includesShadow)
    }

    private var titleBar: some View {
        ZStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))

            HStack(spacing: 0) {
                trafficLights
                Spacer()
                toolbar
            }
        }
        .padding(.horizontal, 14)
        .frame(height: titleBarHeight)
    }

    private var trafficLights: some View {
        HStack(spacing: 8) {
            trafficLight(trafficLightRed)
            trafficLight(trafficLightYellow)
            trafficLight(trafficLightGreen)
        }
    }

    private func trafficLight(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
    }
}
#endif
