//
//  SocketErrorPayload.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 08/08/2026.
//


struct SocketErrorPayload: Decodable {
    let code: String?
    let message: String?
    let timestamp: String?
}