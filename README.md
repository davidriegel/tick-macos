# Tick

A minimal TOTP (Time-based One-Time Password) generator for macOS, built with SwiftUI.

## Features

- Add tokens via QR code (drag & drop an image) or manual entry
- Click any token to copy its current code to the clipboard
- Live countdown showing seconds until the next code
- Secure storage in the macOS Keychain
- Supports SHA1, SHA256, and SHA512 algorithms
- Configurable digits (6–8) and period (30s or 60s)

## Requirements

- macOS 14 or later
- Xcode 15 or later

## Getting Started

1. Clone the repository:
```bash
   git clone git@github.com:davidriegel/tick-macos.git
   cd tick-macos
```
2. Open `Tick.xcodeproj` in Xcode.
3. Build and run (⌘R).

## Status

Work in progress. Core functionality (add, copy, delete, persist) is implemented. Planned next: menu bar access, search, and import/export.
