//
//  EditTokenView.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import SwiftUI

struct EditTokenView: View {
    let token: OTPToken
    var onSave: (OTPToken) -> Void
    var onCancel: () -> Void
    
    @State private var issuer: String
    @State private var account: String
    
    init(token: OTPToken,
         onSave: @escaping (OTPToken) -> Void,
         onCancel: @escaping () -> Void) {
        self.token = token
        self.onSave = onSave
        self.onCancel = onCancel
        _issuer = State(initialValue: token.issuer)
        _account = State(initialValue: token.account)
    }
    
    var body: some View {
        Form {
            Section(LocalizedStringResource.edittokenviewSectionAccount) {
                TextField(.edittokenviewIssuerLabel, text: $issuer, prompt: Text(.edittokenviewIssuerPlaceholder))
                    .autocorrectionDisabled()
                TextField(.edittokenviewAccountLabel, text: $account, prompt: Text(.edittokenviewAccountPlaceholder))
                    .autocorrectionDisabled()
            }

            Section(LocalizedStringResource.edittokenviewSectionDetails) {
                LabeledContent(LocalizedStringResource.edittokenviewLabelAlgorithm, value: token.algorithm.rawValue.uppercased())
                LabeledContent(LocalizedStringResource.edittokenviewLabelDigits, value: "\(token.digits)")
                LabeledContent(LocalizedStringResource.edittokenviewLabelPeriod, value: String(localized: .edittokenviewPeriodValue(token.period)))
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 420, idealWidth: 460, minHeight: 360)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.edittokenviewCancel, action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(.edittokenviewSave, action: save)
                    .disabled(!isValid)
            }
        }
    }
    
    private var isValid: Bool {
        !issuer.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func save() {
        var updated = token
        updated.issuer = issuer.trimmingCharacters(in: .whitespaces)
        updated.account = account.trimmingCharacters(in: .whitespaces)
        onSave(updated)
    }
}
