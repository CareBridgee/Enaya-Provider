//
//  OfferChatView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


import SwiftUI

struct OfferChatView: View {
    @StateObject var viewModel: OfferChatViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: Spacing.s0) {
            chatHeader
            
            if let error = viewModel.errorMessage {
                AlertBanner(style: .error, message: error)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.messages.isEmpty {
                emptyState
            } else {
                messagesList
            }

            inputArea
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Notice", isPresented: $viewModel.showPhoneAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.phoneAlertMessage)
        }
        .alert("Request Cancelled", isPresented: $viewModel.showPatientCancelledAlert) {
            Button("OK", role: .cancel) {
                viewModel.handlePatientCancellationAcknowledged()
            }
        } message: {
            Text("We're sorry, the patient has cancelled this request. We are investigating the reason to ensure your compensation. You will now be redirected to the home screen.")
        }
        .onAppear { viewModel.loadChat() }
    }
    
    // MARK: - Header (Figma Match)
    private var chatHeader: some View {
        HStack(spacing: Spacing.s12) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: IconSize.s24, weight: .semibold))
                    .foregroundColor(.primaryFont)
            }
            
            ZStack(alignment: .bottomTrailing) {
                if let urlString = viewModel.patientImageUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !urlString.isEmpty, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Circle().fill(Color.surfaceVariant)
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .tint(.brandPrimary)
                            }
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            chatAvatarFallback
                        }
                    }
                    .frame(width: Spacing.s40, height: Spacing.s40)
                    .clipShape(Circle())
                } else {
                    chatAvatarFallback
                        .frame(width: Spacing.s40, height: Spacing.s40)
                }
                
                Circle()
                    .fill(Color.success)
                    .frame(width: Spacing.s12, height: Spacing.s12)
                    .overlay(Circle().stroke(Color.surface, lineWidth: Spacing.s2))
            }
            
            VStack(alignment: .leading, spacing: Spacing.s2) {
                Text(viewModel.patientName)
                    .carelyText(style: .heading3, weight: .bold)
                    .foregroundColor(.primaryFont)
                Text("Active Now")
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
            
            Spacer(minLength: Spacing.s0)
            
            
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s12)
        .background(Color.surface)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var chatAvatarFallback: some View {
        Circle()
            .fill(Color.mintSurface)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: IconSize.s16))
            )
    }

    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.s16) {
                    Text("Today")
                        .carelyText(style: .caption, weight: .medium)
                        .padding(.horizontal, Spacing.s12)
                        .padding(.vertical, Spacing.s4)
                        .background(Color.surfaceVariant)
                        .clipShape(Capsule())
                        .padding(.top, Spacing.s16)
                        .padding(.bottom, Spacing.s8)

                    ForEach(viewModel.messages) { message in
                        messageBubble(for: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.bottom, Spacing.s24)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastId = viewModel.messages.last?.id {
                    withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                }
            }
            .onAppear {
                if let lastId = viewModel.messages.last?.id {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Message Bubble (Figma Match)
    private func messageBubble(for message: ChatMessageResponseDTO) -> some View {
        let isMe = viewModel.isCurrentUser(message: message)
        let isPending = viewModel.pendingMessageIds.contains(message.id)
        let isFailed = viewModel.failedMessageIds.contains(message.id)
        let timeString = viewModel.formatTime(dateString: message.createdAt)
        
        return VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.s4) {
            // Text Bubble
            Text(message.content)
                .carelyText(style: .bodyRegular, weight: .regular)
                .foregroundColor(isMe ? .onPrimary : .primaryFont)
                .padding(.horizontal, Spacing.s16)
                .padding(.vertical, Spacing.s12)
                .background(isMe ? Color.brandPrimary : Color.surfaceVariant)
                .clipShape(RoundedRectangle.carely(Radius.r16))
                .opacity(isPending ? 0.6 : 1.0)
            
            // Time & Status below the bubble
            HStack(spacing: Spacing.s4) {
                if isFailed {
                    Button(action: { viewModel.retrySend(messageId: message.id) }) {
                        Label("Failed, tap to retry", systemImage: "exclamationmark.circle.fill")
                            .carelyText(style: .caption, weight: .medium)
                            .foregroundColor(.error)
                    }
                } else {
                    Text(timeString)
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.secondaryFont)
                    
                    if isMe {
                        if isPending {
                            ProgressView().scaleEffect(0.6)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: IconSize.s12))
                                .foregroundColor(.brandPrimary)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.s4)
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }

    // MARK: - Input Area (Figma Match)
    private var inputArea: some View {
        HStack(spacing: Spacing.s12) {
            TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                .carelyText(style: .bodyRegular, weight: .regular)
                .padding(.horizontal, Spacing.s16)
                .padding(.vertical, Spacing.s12)
                .lineLimit(1...4)
            
            Button(action: viewModel.sendMessage) {
                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: Spacing.s48, height: Spacing.s48)
                    .overlay(
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: IconSize.s20))
                            .foregroundColor(.onPrimary)
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.inputText.isEmpty ? 0.6 : 1.0)
        }
        .padding(.horizontal, Spacing.s12)
        .padding(.vertical, Spacing.s8)
        .background(
            Capsule()
                .fill(Color.surface)
                .shadow(color: Color.black.opacity(0.12), radius: Radius.r16, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, Spacing.s8)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: Spacing.s12) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .resizable()
                .scaledToFit()
                .frame(width: IconSize.s32, height: IconSize.s32)
                .foregroundColor(.hint)
            Text("No messages yet")
                .carelyText(style: .bodyLarge, weight: .semiBold)
                .foregroundColor(.primaryFont)
            Spacer()
        }
    }
}
