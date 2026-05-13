//
//  TOTPGenerator.swift
//  Tick
//
//  Created by David Riegel on 13.05.26.
//

import Foundation
import CryptoKit

enum TOTPGenerator {
    
    // MARK: - Public
    
    public static func generate(for token: OTPToken, at date: Date = Date()) -> String {
        let counter = UInt64(date.timeIntervalSince1970) / UInt64(token.period)
        return generateHOTP(secret: token.secret, counter: counter, algorithm: token.algorithm, digits: token.digits)
    }
    
    public static func secondsRemaining(for token: OTPToken, at date: Date = Date()) -> Int {
        let period = token.period
        let elapsed = Int(date.timeIntervalSince1970) % period
        return (period - elapsed)
    }
    
    // MARK: -Private
    
    fileprivate static func generateHOTP(secret: Data, counter: UInt64, algorithm: OTPAlgorithm, digits: Int) -> String {
        var counterBE = counter.bigEndian
        let counterData = Data(bytes: &counterBE, count: 8)
        
        let key = SymmetricKey(data: secret)
        let hash: Data
        
        switch algorithm {
        case .sha1:
            hash = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key))
        case .sha256:
            hash = Data(HMAC<SHA256>.authenticationCode(for: counterData, using: key))
        case .sha512:
            hash = Data(HMAC<SHA512>.authenticationCode(for: counterData, using: key))
        }

        // Dynamic truncation
        let offset = Int(hash[hash.count - 1] & 0x0f)
        let b0 = UInt32(hash[offset] & 0x7f)
        let b1 = UInt32(hash[offset + 1])
        let b2 = UInt32(hash[offset + 2])
        let b3 = UInt32(hash[offset + 3])
        
        let code = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
        
        print(code)
        
        print(code % UInt32(pow(10.0, Double(digits))))
        
        let otp = code % UInt32(pow(10.0, Double(digits)))
        var otpCode = String(otp)
        
        if otp < UInt32(pow(10.0, Double(digits) - 1)) {
            otpCode = String(format: "%0\(digits)d", code)
        }
        
        return otpCode
    }
    
}
