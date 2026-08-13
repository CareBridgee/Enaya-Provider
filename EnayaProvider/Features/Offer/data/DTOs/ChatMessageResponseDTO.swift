//
//  ChatMessageResponseDTO.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation

struct ChatMessageResponseDTO: Codable, Identifiable, Equatable {
    let id: String
    let serviceRequestId: String
    let senderUserId: String
    let senderName: String?
    let senderPhone: String?
    let content: String
    let createdAt: String?
}


struct SendMessageRequestDTO: Encodable {
    let content: String
}

