//
//  GoogleMigrationHelpView.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import SwiftUI

struct GoogleMigrationHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(.migrationhelpTitle)
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HelpStep(number: 1, text: .migrationhelpStep1)
                HelpStep(number: 2, text: .migrationhelpStep2)
                HelpStep(number: 3, text: .migrationhelpStep3)
                HelpStep(number: 4, text: .migrationhelpStep4)
                HelpStep(number: 5, text: .migrationhelpStep5)
                HelpStep(number: 6, text: .migrationhelpStep6)
                HelpStep(number: 7, text: .migrationhelpStep7)
            }

            Text(.migrationhelpHint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct HelpStep: View {
    let number: Int
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)
            Text(text)
                .font(.subheadline)
        }
    }
}
