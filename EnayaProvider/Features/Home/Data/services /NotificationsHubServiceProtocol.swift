//
//  NotificationsHubServiceProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 07/08/2026.
//


import Foundation

protocol NotificationsHubServiceProtocol {
    var onNotificationReceived: ((NotificationResponseDTO) -> Void)? { get set }
    func connectAndSubscribe()
    func disconnect()
}

final class NotificationsSocketDataSource: NotificationsHubServiceProtocol {
    var onNotificationReceived: ((NotificationResponseDTO) -> Void)?

    private let socketClient: SocketClientProtocol
    private let decoder = JSONDecoder()
    private let destination = "/user/queue/notifications"
    private let listenerKey = "NurseGlobalNotifications"

    init(socketClient: SocketClientProtocol) {
        self.socketClient = socketClient
        self.setupSocketEvents()
    }

    private func setupSocketEvents() {
        socketClient.onConnectedListeners[listenerKey] = { [weak self] in
            guard let self = self else { return }
            self.socketClient.subscribe(to: self.destination)
        }

        socketClient.onMessageReceivedListeners[listenerKey] = { [weak self] receivedDestination, body in
            guard let self = self else { return }
            if receivedDestination.contains("/queue/notifications") {
                self.handleMessage(body: body)
            }
        }
    }

    func connectAndSubscribe() {
        socketClient.connect()
    }

    func disconnect() {
        socketClient.unsubscribe(from: destination)
    }

    private func handleMessage(body: String) {
        guard let data = body.data(using: .utf8) else { return }
        do {
            let notification = try decoder.decode(NotificationResponseDTO.self, from: data)
            DispatchQueue.main.async {
                self.onNotificationReceived?(notification)
            }
        } catch {
            print("[NotificationsSocket] Error decoding message: \(error)")
        }
    }
}
