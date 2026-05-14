//
//  TickTests.swift
//  TickTests
//
//  Created by David Riegel on 14.05.26.
//

import Testing
import Foundation
@testable import Tick

// MARK: - RFC 6238 Compliance Tests

struct TOTPGeneratorTests {
    
    private static let sha1Secret = "12345678901234567890".data(using: .ascii)!
    private static let sha256Secret = "12345678901234567890123456789012".data(using: .ascii)!
    private static let sha512Secret = "1234567890123456789012345678901234567890123456789012345678901234".data(using: .ascii)!
    
    // MARK: - SHA1
    
    @Test("SHA1 RFC 6238 vectors", arguments: [
        (TimeInterval(59),         "94287082"),
        (TimeInterval(1111111109), "07081804"),
        (TimeInterval(1111111111), "14050471"),
        (TimeInterval(1234567890), "89005924"),
        (TimeInterval(2000000000), "69279037"),
    ])
    func sha1Vectors(time: TimeInterval, expected: String) {
        let token = OTPToken(
            issuer: "Test",
            account: "rfc",
            secret: Self.sha1Secret,
            algorithm: .sha1,
            digits: 8,
            period: 30
        )
        let code = TOTPGenerator.generate(for: token, at: Date(timeIntervalSince1970: time))
        #expect(code == expected)
    }
    
    // MARK: - SHA256
    
    @Test("SHA256 RFC 6238 vectors", arguments: [
        (TimeInterval(59),         "46119246"),
        (TimeInterval(1111111109), "68084774"),
        (TimeInterval(1111111111), "67062674"),
        (TimeInterval(1234567890), "91819424"),
        (TimeInterval(2000000000), "90698825"),
    ])
    func sha256Vectors(time: TimeInterval, expected: String) {
        let token = OTPToken(
            issuer: "Test",
            account: "rfc",
            secret: Self.sha256Secret,
            algorithm: .sha256,
            digits: 8,
            period: 30
        )
        let code = TOTPGenerator.generate(for: token, at: Date(timeIntervalSince1970: time))
        #expect(code == expected)
    }
    
    // MARK: - SHA512
    
    @Test("SHA512 RFC 6238 vectors", arguments: [
        (TimeInterval(59),         "90693936"),
        (TimeInterval(1111111109), "25091201"),
        (TimeInterval(1111111111), "99943326"),
        (TimeInterval(1234567890), "93441116"),
        (TimeInterval(2000000000), "38618901"),
    ])
    func sha512Vectors(time: TimeInterval, expected: String) {
        let token = OTPToken(
            issuer: "Test",
            account: "rfc",
            secret: Self.sha512Secret,
            algorithm: .sha512,
            digits: 8,
            period: 30
        )
        let code = TOTPGenerator.generate(for: token, at: Date(timeIntervalSince1970: time))
        #expect(code == expected)
    }
    
    // MARK: - 6 digit truncation
    
    @Test("Six digits truncates 8-digit code correctly")
    func sixDigitsTruncation() {
        let token = OTPToken(
            issuer: "Test", account: "test",
            secret: Self.sha1Secret,
            algorithm: .sha1,
            digits: 6,
            period: 30
        )
        
        let code = TOTPGenerator.generate(for: token, at: Date(timeIntervalSince1970: 1111111109))
        #expect(code == "081804")
    }
}
