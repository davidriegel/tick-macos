//
//  CircularProgressBarView.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import SwiftUI

struct CircularProgressBarView: View {
    let progress: Double
    let lineWidth: CGFloat = 5
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.3), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.smooth, value: progress)
        }
    }
}

#Preview {
    CircularProgressBarView(progress: 0.25)
}
