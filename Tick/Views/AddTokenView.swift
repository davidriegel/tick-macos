//
//  AddTokenView.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import SwiftUI

struct AddTokenView: View {
    @State private var issuer = ""
    @State private var account = ""
    @State private var secretBase32 = ""
    @State private var algorithm: OTPAlgorithm = .sha1
    @State private var digits: Int = 6
    @State private var period: Int = 30
    @State private var isTargeted = false
    @State private var error: String?
    
    var onAdd: (OTPToken) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        DropZone(isTargeted: $isTargeted, onImage: handleImage(_:))
                        .frame(height: 140)
                        .padding(20)

        Divider()
        
        Form {
            Section("Account") {
                TextField("Issuer (e.g. GitHub)", text: $issuer)
                    .autocorrectionDisabled()
                    .font(.body)
                TextField("Account (e.g. user@example.com)", text: $account)
                    .autocorrectionDisabled()
                    .font(.body)
            }
            .font(.title2)
            
            Section("Secret") {
                TextField("Base32 secret", text: $secretBase32)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))
            }
            .font(.title2)
            
            Section("Advanced") {
                Picker("Algorithm", selection: $algorithm) {
                    Text("SHA1").tag(OTPAlgorithm.sha1)
                    Text("SHA256").tag(OTPAlgorithm.sha256)
                    Text("SHA512").tag(OTPAlgorithm.sha512)
                }
                .font(.body)
                
                Picker("Digits", selection: $digits) {
                    Text("6").tag(6)
                    Text("7").tag(7)
                    Text("8").tag(8)
                }
                .font(.body)
                
                Picker("Period", selection: $period) {
                    Text("30 seconds").tag(30)
                    Text("60 seconds").tag(60)
                }
                .font(.body)
            }
            .font(.title2)
            

            if let error {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: add).disabled(!isValid)
            }
        }
    }
    
    private var isValid: Bool {
        !issuer.trimmingCharacters(in: .whitespaces).isEmpty &&
        !secretBase32.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func add() {
        guard let secret = Data(base32Encoded: secretBase32), !secret.isEmpty else {
            error = "Invalid Base32 secret"
            return
        }
        
        let token = OTPToken(
            issuer: issuer, account: account, secret: secret,
            algorithm: algorithm, digits: digits, period: period
        )
        
        onAdd(token)
    }
    
    private func handleImage(_ image: NSImage) {
        error = nil
        
        do {
            let token = try OTPParser.parseQRCode(from: image)
            
            issuer = token.issuer
            account = token.account
            secretBase32 = token.secret.base32EncodedString()
            algorithm = token.algorithm
            digits = token.digits
            period = token.period
        } catch ParsingError.qrCodeNotFound {
            error = "No QR code found in image"
        } catch ParsingError.invalidQRCode, ParsingError.invalidSecret {
            error = "Invalid QR Code"
        } catch let e {
            error = e.localizedDescription
        }
    }
}

#Preview {
    AddTokenView { _ in
        //
    } onCancel: {
        //
    }
}
