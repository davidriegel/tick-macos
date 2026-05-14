//
//  OTPToken.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation

struct OTPToken: Identifiable, Codable, Hashable {
    let id: UUID
    var issuer: String
    var account: String
    let secret: Data
    let algorithm: OTPAlgorithm
    let digits: Int
    let period: Int
    var sortIndex: Int
    
    init(issuer: String, account: String, secret: Data, algorithm: OTPAlgorithm = .sha1, digits: Int = 6, period: Int = 30, sortIndex: Int = 0) {
        self.id = UUID()
        self.issuer = issuer
        self.account = account
        self.secret = secret
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.sortIndex = sortIndex
    }
}
