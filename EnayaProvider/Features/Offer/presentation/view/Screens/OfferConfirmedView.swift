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
        ZStack {
            Color.backGround.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.s24) {
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
                        
                        HStack(spacing: Spacing.s16) {
                            OfferStatChip(
                                icon: "mappin.and.ellipse",
                                title: "Distance",
                                value: viewModel.distanceText,
                                isPrimaryStyle: true
                            )
                            OfferStatChip(
                                icon: "cross.case.fill",
                                title: "Service",
                                value: viewModel.serviceName,
                                isPrimaryStyle: false
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.s20)
                    .padding(.bottom, Spacing.s24)
                    .frame(maxWidth: .infinity)
                }
                
                // Bottom Buttons
                VStack(spacing: Spacing.s12) {
                    SecondaryButton(
                        title: "View Offer Details",
                        icon: "doc.text",
                        action: viewModel.openDetails
                    )

                    SecondaryButton(
                        title: "Scan QR to Complete",
                        icon: "qrcode.viewfinder",
                        isLoading: viewModel.isProcessing,
                        action: {
                            print("[OfferConfirmedView] Scan QR to Complete button tapped")
                            showingImageSourceDialog = true
                        }
                    )

                    PrimaryButton(
                        title: "Cancel",
                        action: viewModel.presentCancelSheet
                    )
                }
                .padding(.horizontal, Spacing.s20)
                .padding(.top, Spacing.s16)
                .padding(.bottom, Spacing.s24)
                .background(Color.backGround.ignoresSafeArea(edges: .bottom))
            }
        }
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
        VStack(spacing: Spacing.s16) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.12))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.brandPrimary)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: Spacing.s8) {
                Text("Offer Confirmed!")
                    .carelyText(style: .heading2, weight: .bold)
                    .foregroundColor(.primaryFont)

                Text("Your patient is waiting for you")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .padding(.bottom, Spacing.s8)
    }
}

