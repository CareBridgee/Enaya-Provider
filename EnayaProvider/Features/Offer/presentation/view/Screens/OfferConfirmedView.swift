//
//  OfferConfirmedView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


import SwiftUI

struct OfferConfirmedView: View {
    @ObservedObject var coordinator: OfferCoordinator
    @StateObject var viewModel: OfferConfirmedViewModel
    
    @State private var showingImageSourceDialog = false
    @State private var showingImagePicker = false
    @State private var pickerSourceType: ImagePicker.SourceType = .photoLibrary

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s16) {
                statusHero
                
                if let error = viewModel.errorMessage {
                    AlertBanner(style: .error, message: error)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                AlertBanner(
                    style: .info,
                    message: "You can cancel within 2 minutes after the visit starts. After that, a cancellation fee will apply."
                )
                
                OfferPatientCard(
                    name: viewModel.patientName,
                    ageText: viewModel.patientAge,
                    caption: "Estimated Arrival",
                    captionValue: viewModel.estimatedArrivalText,
                    imageUrl: viewModel.patientImageUrl,
                    onCall: viewModel.callPatientTapped,
                    onMessage: viewModel.openChatTapped
                )
                
                HStack(spacing: Spacing.s12) {
                    OfferStatChip(icon: "location.fill", title: "Distance", value: viewModel.distanceText)
                    OfferStatChip(icon: "briefcase.fill", title: "Service", value: viewModel.serviceName)
                }

                VStack(spacing: Spacing.s12) {
                    SecondaryButton(title: "View Offer Details", icon: "doc.text", action: viewModel.openDetails)

                    PrimaryButton(
                        title: "Scan QR to Complete",
                        icon: "qrcode.viewfinder",
                        isLoading: viewModel.isProcessing,
                        action: {
                            print("[OfferConfirmedView] Scan QR to Complete button tapped")
                            showingImageSourceDialog = true
                        }
                    )

                    Button(action: viewModel.presentCancelSheet) {
                        Text("Cancel")
                            .carelyText(style: .button, weight: .semiBold)
                            .foregroundColor(.onErrorContainer)
                            .frame(maxWidth: .infinity)
                            .frame(height: CarelyButtonSize.medium.height)
                            .background(Color.errorContainer)
                            .clipShape(RoundedRectangle.carely(Radius.r12))
                    }
                }
                .padding(.top, Spacing.s8)
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s24)
            .padding(.bottom, Spacing.s32)
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadDetails()
        }
        .confirmationDialog("Select QR Code Source", isPresented: $showingImageSourceDialog, titleVisibility: .visible) {
            Button("Take Photo (Camera)") {
                print("[OfferConfirmedView] QR Source selected: Take Photo (Camera)")
                pickerSourceType = .camera
                showingImagePicker = true
            }
            Button("Choose from Gallery") {
                print("[OfferConfirmedView] QR Source selected: Choose from Gallery")
                pickerSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {
                print("[OfferConfirmedView] QR Source selection cancelled")
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: pickerSourceType) { image in
                viewModel.processScannedImage(image)
            }
        }
        .alert("Notice", isPresented: $viewModel.showPhoneAlert) {
            Button("OK", role: .cancel) { }
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
    }

    private var statusHero: some View {
        VStack(spacing: Spacing.s12) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Offer Confirmed!")
                .carelyText(style: .heading2, weight: .bold)
                .foregroundColor(.primaryFont)

            Text("Your patient is waiting for you")
                .carelyText(style: .bodyRegular, weight: .regular)
                .foregroundColor(.secondaryFont)
        }
        .padding(.bottom, Spacing.s8)
    }
}

