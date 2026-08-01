//
//  DemoEntry.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

#if DEBUG
import SwiftUI

struct DemoEntry: Identifiable {
    let id = UUID()
    let issuer: String
    let account: String
    let code: String
    let secondsRemaining: Int
    var period: Int = 30

    var presentation: TokenPresentation {
        TokenPresentation(
            id: id,
            issuer: issuer,
            account: account,
            code: code,
            secondsRemaining: secondsRemaining,
            progress: Double(secondsRemaining) / Double(period)
        )
    }

    static let showcase: [DemoEntry] = [
        DemoEntry(issuer: "Amazon", account: "example@email.com", code: "090312", secondsRemaining: 11),
        DemoEntry(issuer: "GitHub", account: "example@email.com", code: "580640", secondsRemaining: 11),
        DemoEntry(issuer: "Posteo", account: "example@email.com", code: "482030", secondsRemaining: 11),
        DemoEntry(issuer: "Trade Republic", account: "John Doe", code: "031942", secondsRemaining: 11),
        DemoEntry(issuer: "Instagram", account: "example@email.com", code: "348994", secondsRemaining: 11),
        DemoEntry(issuer: "Workday", account: "example@email.com", code: "934755", secondsRemaining: 11),
        DemoEntry(issuer: "Discord", account: "example@email.com", code: "195542", secondsRemaining: 11)
    ]
}

extension Color {
    static let brandAccent = Color("AccentColor", bundle: .main)
}
#endif
