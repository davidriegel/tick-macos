//
//  TokenPresentation.swift
//  Tick
//
//  Created by David Riegel on 01.08.26.
//

import Foundation

struct TokenPresentation: Identifiable, Hashable {
    let id: UUID
    let issuer: String
    let account: String
    let code: String
    let secondsRemaining: Int
    let progress: Double

    init(
        id: UUID = UUID(),
        issuer: String,
        account: String,
        code: String,
        secondsRemaining: Int,
        progress: Double
    ) {
        self.id = id
        self.issuer = issuer
        self.account = account
        self.code = code
        self.secondsRemaining = secondsRemaining
        self.progress = progress
    }

    init(token: OTPToken, at date: Date = .now) {
        self.init(
            id: token.id,
            issuer: token.issuer,
            account: token.account,
            code: TOTPGenerator.generate(for: token, at: date),
            secondsRemaining: TOTPGenerator.secondsRemaining(for: token, at: date),
            progress: TOTPGenerator.progress(for: token, at: date)
        )
    }

    var formattedCode: String {
        guard code.count == 6 else { return code }
        let middleIndex = code.index(code.startIndex, offsetBy: 3)
        return "\(code[..<middleIndex]) \(code[middleIndex...])"
    }
}
