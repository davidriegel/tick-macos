//
//  AddTokenView.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import SwiftUI

struct AddTokenView: View {
    @State private var showingMigrationHelp = false
    @State private var issuer = ""
    @State private var account = ""
    @State private var secretBase32 = ""
    @State private var algorithm: OTPAlgorithm = .sha1
    @State private var digits: Int = 6
    @State private var period: Int = 30
    @State private var isTargeted = false
    @State private var error: String?
    
    var onAdd: (OTPToken) -> Void
    var onBulkInsert: ([OTPToken]) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        DropZone(isTargeted: $isTargeted, onImage: handleImage(_:))
                        .frame(height: 140)
                        .padding(20)
        
        Button {
            showingMigrationHelp = true
        } label: {
            Label(.addtokenviewMigrationCta, systemImage: "questionmark.circle")
        }
        .buttonStyle(.borderless)
        .font(.caption)
        .foregroundStyle(.secondary)
        .popover(isPresented: $showingMigrationHelp, arrowEdge: .top) {
            GoogleMigrationHelpView()
                .frame(width: 360)
                .padding()
        }

        Divider()
        
        Form {
            Section(LocalizedStringResource.addtokenviewSectionAccount) {
                TextField(.addtokenviewIssuerPlaceholder, text: $issuer)
                    .autocorrectionDisabled()
                    .font(.body)
                TextField(.addtokenviewAccountPlaceholder, text: $account)
                    .autocorrectionDisabled()
                    .font(.body)
            }
            .font(.title2)

            Section(LocalizedStringResource.addtokenviewSectionSecret) {
                TextField(.addtokenviewSecretPlaceholder, text: $secretBase32)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))
            }
            .font(.title2)

            Section(LocalizedStringResource.addtokenviewSectionAdvanced) {
                Picker(.addtokenviewPickerAlgorithm, selection: $algorithm) {
                    Text("SHA1").tag(OTPAlgorithm.sha1)
                    Text("SHA256").tag(OTPAlgorithm.sha256)
                    Text("SHA512").tag(OTPAlgorithm.sha512)
                }
                .font(.body)

                Picker(.addtokenviewPickerDigits, selection: $digits) {
                    Text("6").tag(6)
                    Text("7").tag(7)
                    Text("8").tag(8)
                }
                .font(.body)

                Picker(.addtokenviewPickerPeriod, selection: $period) {
                    Text(.addtokenviewPeriod30).tag(30)
                    Text(.addtokenviewPeriod60).tag(60)
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
                Button(.addtokenviewCancel, action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(.addtokenviewAdd, action: add).disabled(!isValid)
            }
        }
    }
    
    private var isValid: Bool {
        !issuer.trimmingCharacters(in: .whitespaces).isEmpty &&
        !secretBase32.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func add() {
        guard let secret = Data(base32Encoded: secretBase32), !secret.isEmpty else {
            error = String(localized: .addtokenviewErrorInvalidSecret)
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
            let result = try OTPParser.parseQRCode(from: image)
            
            switch result {
            case .single(let token):
                issuer = token.issuer
                account = token.account
                secretBase32 = token.secret.base32EncodedString()
                algorithm = token.algorithm
                digits = token.digits
                period = token.period
            case .migration(let tokens):
                onBulkInsert(tokens)
            }
        } catch let e as ParsingError {
            error = e.errorDescription
        } catch let e {
            error = e.localizedDescription
        }
    }
}

#Preview {
    AddTokenView { _ in
        //
    } onBulkInsert: { _ in
        //
    } onCancel: {
        //
    }
}
