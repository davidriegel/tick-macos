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
            Text("Import from Google Authenticator")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HelpStep(number: 1, text: "Open Google Authenticator on your phone")
                HelpStep(number: 2, text: "Tap the menu item")
                HelpStep(number: 3, text: "Select \"Transfer accounts\" → \"Export accounts\"")
                HelpStep(number: 4, text: "Verify your identity if asked")
                HelpStep(number: 5, text: "Select the accounts you want to transfer")
                HelpStep(number: 6, text: "Take a screenshot of the QR code(s) shown")
                HelpStep(number: 7, text: "Drop the screenshot into the area above")
            }
            
            Text("Google may generate multiple QR codes if you have many accounts. Drop them one by one.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct HelpStep: View {
    let number: Int
    let text: String
    
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
