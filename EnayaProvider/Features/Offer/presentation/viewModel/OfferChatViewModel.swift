//
//  OfferChatViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import Foundation
import UIKit
import SwiftUI

@MainActor
final class OfferChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageResponseDTO] = []
    @Published var inputText: String = ""
    @Published var isLoading = true
    
    @Published var pendingMessageIds: Set<String> = []
    @Published var failedMessageIds: Set<String> = []

    @Published var errorMessage: String?
    @Published var showPhoneAlert = false
    @Published var phoneAlertMessage = ""
    
    @Published var showPatientCancelledAlert = false

    let patientName: String
    let patientImageUrl: String?
    let patientPhone: String
    let coordinator: OfferCoordinator

    private let reservationId: String
    private let currentUserId: String
    private let chatRepository: ChatRepositoryProtocol
    private let observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol
    
    private var socketTask: Task<Void, Never>?
    private var reservationTask: Task<Void, Never>?

    init(
        reservationId: String,
        patientName: String,
        patientImageUrl: String?,
        patientPhone: String,
        currentUserId: String,
        chatRepository: ChatRepositoryProtocol,
        observeReservationEventsUseCase: ObserveReservationEventsUseCaseProtocol,
        coordinator: OfferCoordinator
    ) {
        self.reservationId = reservationId
        self.patientName = patientName
        self.patientImageUrl = patientImageUrl
        self.patientPhone = patientPhone
        self.currentUserId = currentUserId
        self.chatRepository = chatRepository
        self.observeReservationEventsUseCase = observeReservationEventsUseCase
        self.coordinator = coordinator
        print("----------OfferChatViewModel initialized with reservationId: \(reservationId), patientName: \(patientName), patientPhone: \(patientPhone)")
    }

    func loadChat() {
        Task {
            isLoading = true
            do {
                messages = try await chatRepository.fetchHistory(reservationId: reservationId)
            } catch {
                displayTemporaryError("Failed to load chat history.")
                print("----------Error fetching chat history for reservationId \(reservationId): \(error)")
            }
            startObservingSocket()
            startObservingReservation()
            print("----------Started observing socket and reservation events for reservationId: \(reservationId)")
            isLoading = false
        }
    }

    private func startObservingSocket() {
        socketTask?.cancel()
        socketTask = Task { @MainActor in
            do{
                for await newMessage in chatRepository.observeMessages(reservationId: reservationId) {
                    handleIncoming(newMessage)
                }
            }catch{
                displayTemporaryError("Failed to observe.")
                print("----------Error observing socket messages for reservationId \(reservationId): \(error)")
            }
            
        }
    }
    
    private func startObservingReservation() {
        reservationTask?.cancel()
        reservationTask = Task { @MainActor in
            for await event in observeReservationEventsUseCase.execute(reservationId: reservationId) {
                if event.type.uppercased() == "REQUEST_CANCELLED" {
                    if !self.coordinator.isNurseCancelling {
                        self.showPatientCancelledAlert = true
                    }
                }
            }
        }
    }

    private func handleIncoming(_ newMessage: ChatMessageResponseDTO) {
        if messages.contains(where: { $0.id == newMessage.id }) { return }

        if newMessage.senderUserId == currentUserId {
            if let pendingIndex = messages.firstIndex(where: {
                $0.id.hasPrefix("PENDING_") &&
                $0.content.trimmingCharacters(in: .whitespacesAndNewlines) == newMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
            }) {
                let oldId = messages[pendingIndex].id
                pendingMessageIds.remove(oldId)
                failedMessageIds.remove(oldId)
                withAnimation { messages[pendingIndex] = newMessage }
                return
            }
        }
        
        withAnimation { messages.append(newMessage) }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        let pendingId = "PENDING_\(UUID().uuidString)"
        let pendingMessage = ChatMessageResponseDTO(
            id: pendingId,
            serviceRequestId: reservationId,
            senderUserId: currentUserId,
            senderName: "You",
            senderPhone: "",
            content: text,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        withAnimation { messages.append(pendingMessage) }
        pendingMessageIds.insert(pendingId)

        chatRepository.sendSocketMessage(reservationId: reservationId, content: text)
        
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if self.pendingMessageIds.contains(pendingId) {
                self.failedMessageIds.insert(pendingId)
            }
        }
    }

    func retrySend(messageId: String) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
        let content = messages[index].content
        withAnimation { messages.remove(at: index) }
        failedMessageIds.remove(messageId)
        pendingMessageIds.remove(messageId)
        inputText = content
        sendMessage()
    }

    func callPatientTapped() {
        guard !patientPhone.isEmpty, let url = URL(string: "tel://\(patientPhone)") else {
            phoneAlertMessage = "Phone number is not available."
            showPhoneAlert = true
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = patientPhone
            phoneAlertMessage = "Calls are not supported on this device. Patient's number \(patientPhone) has been copied to your clipboard."
            showPhoneAlert = true
        }
    }

    func isCurrentUser(message: ChatMessageResponseDTO) -> Bool {
        message.senderUserId == currentUserId
    }

    func formatTime(dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: dateString)

        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: dateString)
        }

        guard let resolvedDate = date else { return "" }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        return outputFormatter.string(from: resolvedDate)
    }

    private func displayTemporaryError(_ message: String) {
        withAnimation { self.errorMessage = message }
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if self.errorMessage == message {
                withAnimation { self.errorMessage = nil }
            }
        }
    }
    
    func handlePatientCancellationAcknowledged() {
        coordinator.dismissEntireFlow()
    }

    deinit {
        socketTask?.cancel()
        reservationTask?.cancel()
    }
}
