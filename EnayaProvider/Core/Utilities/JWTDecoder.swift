//
//  JWTDecoder.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation

enum JWTDecoder {
    static func userId(fromToken token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }
        var payloadSegment = String(segments[1])
        while payloadSegment.count % 4 != 0 {
            payloadSegment += "="
        }
        guard let data = Data(base64Encoded: payloadSegment),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["sub"] as? String
    }
}