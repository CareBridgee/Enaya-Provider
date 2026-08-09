//
//  ChatRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//

import Foundation

final class ChatRepositoryImpl: ChatRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let socketClient: SocketClientProtocol
    private let encoder = JSONEncoder()

    init(networkClient: NetworkClientProtocol, socketClient: SocketClientProtocol) {
        self.networkClient = networkClient
        self.socketClient = socketClient
    }

    var isConnected: Bool { socketClient.isConnected }

    func fetchHistory(reservationId: String) async throws -> [ChatMessageResponseDTO] {
        try await networkClient.request(ChatEndpoint.getHistory(reservationId: reservationId))
    }

    func sendMessage(reservationId: String, content: String) async throws -> ChatMessageResponseDTO? {
        if socketClient.isConnected {
            sendSocketMessage(reservationId: reservationId, content: content)
            return nil
        } else {
            let endpoint = ChatEndpoint.sendMessage(reservationId: reservationId, payload: SendMessageRequestDTO(content: content))
            return try await networkClient.request(endpoint)
        }
    }

    func sendSocketMessage(reservationId: String, content: String) {
            let destination = "/app/chat/\(reservationId)/send"
            
            let jsonString = "{\"content\":\"\(content)\"}"
            
            socketClient.send(
                to: destination,
                headers: ["content-type": "application/json;charset=UTF-8"],
                body: jsonString
            )
        }
    func observeMessages(reservationId: String) -> AsyncStream<ChatMessageResponseDTO> {
            AsyncStream { continuation in
                let topic = "/topic/chat/\(reservationId)"
                let listenerKey = "Chat_\(reservationId)"

                socketClient.onConnectedListeners[listenerKey] = { [weak socketClient] in
                    socketClient?.subscribe(to: topic)
                }
                socketClient.subscribe(to: topic)

                socketClient.onMessageReceivedListeners[listenerKey] = { destination, body in
                    guard destination == topic, let data = body.data(using: .utf8) else { return }
                    
                    do {
                        let message = try JSONDecoder().decode(ChatMessageResponseDTO.self, from: data)
                        continuation.yield(message)
                    } catch {
                        print("❌ [Chat Socket Decode Error]: \(error)")
                        print("❌ [Received Payload]: \(body)")
                    }
                }

                continuation.onTermination = { [weak socketClient] _ in
                    socketClient?.unsubscribe(from: topic)
                    socketClient?.onMessageReceivedListeners.removeValue(forKey: listenerKey)
                    socketClient?.onConnectedListeners.removeValue(forKey: listenerKey)
                }
            }
        }

}
