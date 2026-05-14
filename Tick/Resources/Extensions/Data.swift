//
//  Data.swift
//  Tick
//
//  Created by David Riegel on 14.05.26.
//

import Foundation

extension Data {
    init?(base32Encoded string: String) {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let cleaned = string
            .uppercased()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        var bytes = [UInt8]()
        var buffer: UInt32 = 0
        var bitsLeft = 0
        
        for char in cleaned {
            guard let index = alphabet.firstIndex(of: char) else { return nil }
            let value = alphabet.distance(from: alphabet.startIndex, to: index)
            
            buffer = (buffer << 5) | UInt32(value)
            bitsLeft += 5
            
            if bitsLeft >= 8 {
                bitsLeft -= 8
                bytes.append(UInt8((buffer >> bitsLeft) & 0xff))
            }
        }
        
        self.init(bytes)
    }
    
    func base32EncodedString() -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        guard !isEmpty else { return "" }
        
        var result = ""
        var buffer: UInt32 = 0
        var bitsLeft = 0
        
        for byte in self {
            buffer = (buffer << 8) | UInt32(byte)
            bitsLeft += 8
            
            while bitsLeft >= 5 {
                bitsLeft -= 5
                let index = Int((buffer >> bitsLeft) & 0x1F)
                result.append(alphabet[index])
            }
        }
        
        // Restbits auffüllen, falls Datenlänge kein Vielfaches von 5 Bits
        if bitsLeft > 0 {
            let index = Int((buffer << (5 - bitsLeft)) & 0x1F)
            result.append(alphabet[index])
        }
        
        return result
    }
}
