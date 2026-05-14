//
//  GoogleMigrationParser.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import Foundation

enum MigrationError: Error, LocalizedError {
    case notAMigrationURL
    case invalidData
    case malformedProtobuf
    
    var errorDescription: String? {
        switch self {
        case .notAMigrationURL: return "Not a Google Authenticator migration URL"
        case .invalidData: return "Migration data is not valid base64"
        case .malformedProtobuf: return "Migration data is malformed"
        }
    }
}

enum GoogleMigrationParser {
    
    // MARK: - Public
    
    static func parse(url: URL) throws -> [OTPToken] {
        guard url.scheme == "otpauth-migration",
              url.host == "offline" else {
            throw MigrationError.notAMigrationURL
        }
        
        guard let dataParam = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "data" })?
                .value,
              let bytes = Data(base64Encoded: dataParam) else {
            throw MigrationError.invalidData
        }
        
        return try parsePayload(bytes)
    }
    
    // MARK: - Private
    
    private struct Reader {
        let data: Data
        var offset: Int = 0
        
        var isAtEnd: Bool { offset >= data.count }
        
        mutating func readVarint() throws -> UInt64 {
            var result: UInt64 = 0
            var shift: UInt64 = 0
            while !isAtEnd {
                let byte = data[offset]
                offset += 1
                result |= UInt64(byte & 0x7F) << shift
                if (byte & 0x80) == 0 { return result }
                shift += 7
                if shift >= 64 { throw MigrationError.malformedProtobuf }
            }
            throw MigrationError.malformedProtobuf
        }
        
        mutating func readLengthDelimited() throws -> Data {
            let length = Int(try readVarint())
            guard offset + length <= data.count else {
                throw MigrationError.malformedProtobuf
            }
            let slice = data.subdata(in: offset..<(offset + length))
            offset += length
            return slice
        }
        
        mutating func readTag() throws -> (fieldNumber: Int, wireType: Int) {
            let raw = try readVarint()
            return (Int(raw >> 3), Int(raw & 0x07))
        }
        
        mutating func skip(wireType: Int) throws {
            switch wireType {
            case 0: _ = try readVarint()
            case 2: _ = try readLengthDelimited()
            default: throw MigrationError.malformedProtobuf
            }
        }
    }
    
    private static func parsePayload(_ data: Data) throws -> [OTPToken] {
        var reader = Reader(data: data)
        var tokens: [OTPToken] = []
        
        while !reader.isAtEnd {
            let (fieldNumber, wireType) = try reader.readTag()
            
            if fieldNumber == 1 && wireType == 2 {
                let bytes = try reader.readLengthDelimited()
                if let token = try parseOtpParameters(bytes) {
                    tokens.append(token)
                }
            } else {
                try reader.skip(wireType: wireType)
            }
        }
        
        return tokens
    }
    
    private static func parseOtpParameters(_ data: Data) throws -> OTPToken? {
        var reader = Reader(data: data)
        
        var secret: Data?
        var name: String = ""
        var issuer: String = ""
        var algorithmRaw: Int = 1
        var digitsRaw: Int = 1
        var typeRaw: Int = 2
        
        while !reader.isAtEnd {
            let (fieldNumber, wireType) = try reader.readTag()
            
            switch (fieldNumber, wireType) {
            case (1, 2):  // secret
                secret = try reader.readLengthDelimited()
            case (2, 2):  // name (= account)
                name = String(data: try reader.readLengthDelimited(), encoding: .utf8) ?? ""
            case (3, 2):  // issuer
                issuer = String(data: try reader.readLengthDelimited(), encoding: .utf8) ?? ""
            case (4, 0):  // algorithm
                algorithmRaw = Int(try reader.readVarint())
            case (5, 0):  // digits
                digitsRaw = Int(try reader.readVarint())
            case (6, 0):  // type
                typeRaw = Int(try reader.readVarint())
            default:
                try reader.skip(wireType: wireType)
            }
        }
        
        guard typeRaw == 2 else { return nil }
        guard let secret, !secret.isEmpty else { return nil }
        
        let algorithm: OTPAlgorithm = {
            switch algorithmRaw {
            case 2: return .sha256
            case 3: return .sha512
            default: return .sha1
            }
        }()
        
        let digits = digitsRaw == 2 ? 8 : 6
        
        return OTPToken(
            issuer: issuer,
            account: name,
            secret: secret,
            algorithm: algorithm,
            digits: digits,
            period: 30   // Google Authenticator only uses 30s
        )
    }
}
