//
//  OTPParser.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import Vision
import AppKit

enum ParsingError: String, Error {
    case qrCodeNotFound
    case invalidQRCode
    case invalidSecret
    
    var errorDescription: String? {
        switch self {
        case .qrCodeNotFound: return "No QR code found in image"
        case .invalidQRCode, .invalidSecret: return "Data from QR Code couldn't be read"
        }
    }
}

enum OTPParser {
    
    // MARK: - Public
    
    public static func parseQRCode(from image: NSImage) throws -> OTPToken {
        let payload = try extractQRCodeURL(image)
        let token = try parseOTPAuth(payload)
        
        return token
    }
    
    // MARK: - Private
    
    private static func extractQRCodeURL(_ image: NSImage) throws -> URL {
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { throw ParsingError.qrCodeNotFound }
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        let handler = VNImageRequestHandler(cgImage: cg)
        try handler.perform([request])
        guard let result = request.results?.first as? VNBarcodeObservation else { throw ParsingError.qrCodeNotFound }
        guard let payload = result.payloadStringValue, let payloadURL = URL(string: payload) else { throw ParsingError.invalidQRCode }
        return payloadURL
    }
    
    private static func parseOTPAuth(_ url: URL) throws -> OTPToken {
        guard url.scheme == "otpauth",
              url.host == "totp",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let secretItem = components.queryItems?.first(where: { $0.name == "secret" }),
              let secretBase32 = secretItem.value,
              let secret = Data(base32Encoded: secretBase32) else { throw ParsingError.invalidSecret }

        let label = url.path.dropFirst()
        let parts = label.split(separator: ":", maxSplits: 1).map(String.init)
        let issuerFromLabel = parts.count == 2 ? parts[0] : ""
        let account = parts.last ?? ""
        let issuer = components.queryItems?.first(where: { $0.name == "issuer" })?.value ?? issuerFromLabel

        let algo: OTPAlgorithm = {
            switch components.queryItems?.first(where: { $0.name == "algorithm" })?.value?.uppercased() {
            case "SHA256": return .sha256
            case "SHA512": return .sha512
            default: return .sha1
            }
        }()
        let digits = Int(components.queryItems?.first(where: { $0.name == "digits" })?.value ?? "") ?? 6
        let period = Int(components.queryItems?.first(where: { $0.name == "period" })?.value ?? "") ?? 30

        return OTPToken(issuer: issuer, account: account, secret: secret,
                         algorithm: algo, digits: digits, period: period)
    }
}
