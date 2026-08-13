//
//  ChatRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation

protocol ChatRepositoryProtocol {
    func fetchHistory(reservationId: String) async throws -> [ChatMessageResponseDTO]
    func sendMessage(reservationId: String, content: String) async throws -> ChatMessageResponseDTO?
    func observeMessages(reservationId: String) -> AsyncStream<ChatMessageResponseDTO>
    var isConnected: Bool { get }
    func sendSocketMessage(reservationId: String, content: String)
}
