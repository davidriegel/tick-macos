# Tick Authenticator

A clean, lightweight TOTP authenticator for macOS. Generate two-factor 
authentication codes from the menu bar, with everything stored locally 
in the macOS Keychain.

## Features

- **Menu bar access** – Click to see all your codes, click a token to copy
- **QR code import** – Drag any QR code screenshot into the app
- **Google Authenticator migration** – Import all your tokens at once 
  via the official Google Authenticator export
- **Live countdown** – See seconds remaining before the next code
- **Secure storage** – All tokens stored in the macOS Keychain, never 
  transmitted
- **Fully offline** – No network access, no analytics, no telemetry
- **Standards-compliant** – RFC 6238 (TOTP) with SHA-1, SHA-256, SHA-512

## Privacy

Tick is built privacy-first. No accounts, no sign-up, no servers. Your 
2FA tokens never leave your Mac. See the [Privacy Policy](https://davidriegel.app/tick/privacy) 
for details.

## Requirements

- macOS 26 or later
- Xcode 26 or later (for building from source)

## Installation

### From the Mac App Store
[Coming soon]

### From source
\`\`\`bash
git clone https://github.com/davidriegel/tick-macos.git
cd tick-macos
open Tick.xcodeproj
\`\`\`

Build and run with ⌘R in Xcode.

## Migrating from Google Authenticator

1. Open Google Authenticator on your phone
2. Tap the menu → "Transfer accounts" → "Export accounts"
3. Verify your identity if asked
4. Select the accounts to transfer
5. Take a screenshot of the QR code(s)
6. Open Tick → click "+ Add token" → drop the screenshot into the app

Tokens are imported in one step, with duplicate detection.

## Technical Overview

- **Language:** Swift 5.10+, SwiftUI
- **Persistence:** macOS Data Protection Keychain (sandboxed)
- **TOTP:** Apple CryptoKit (HMAC-SHA1/256/512)
- **QR detection:** Apple Vision framework
- **Google migration:** Custom Protocol Buffers parser

## Contributing

Contributions are welcome. Feel free to open issues for bugs or feature 
requests, or submit pull requests.

For larger changes, please open an issue first to discuss the approach.

## License

[MIT](LICENSE) © David Riegel

## Acknowledgements

- RFC 6238 test vectors for TOTP verification
- Google Authenticator migration format reverse-engineered from the 
  `otpauth-migration://` URL scheme
