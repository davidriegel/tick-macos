//
//  DropZone.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import SwiftUI
import UniformTypeIdentifiers


struct DropZone: View {
    @Binding var isTargeted: Bool
    var onImage: (NSImage) -> Void
    @State private var showPicker = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                isTargeted ? Color.accentColor : Color.secondary.opacity(0.4),
                style: StrokeStyle(lineWidth: 2, dash: [6])
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("Drop QR code image here")
                        .font(.callout)
                    Button("Choose Image…") { showPicker = true }
                        .buttonStyle(.link)
                }
            }
            .onDrop(of: [.image, .fileURL], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first else { return false }
                
                if provider.canLoadObject(ofClass: NSImage.self) {
                    _ = provider.loadObject(ofClass: NSImage.self) { image, _ in
                        guard let image = image as? NSImage else { return }
                        Task { @MainActor in
                            onImage(image)
                        }
                    }
                    return true
                }
                
                return false
            }
            .fileImporter(isPresented: $showPicker, allowedContentTypes: [.image]) { result in
                guard let fileURL = try? result.get(), fileURL.startAccessingSecurityScopedResource() else { return }
                if let imageData = try? Data(contentsOf: fileURL), let image = NSImage(data: imageData) {
                    onImage(image)
                }
                fileURL.stopAccessingSecurityScopedResource()
            }
    }
}
