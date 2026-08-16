//
//  ProfileView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var showLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s24) {
                if viewModel.isLoading && viewModel.profile == nil {
                    ProfileSkeletonView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.error)
                        .padding()
                } else if let profile = viewModel.profile {
                    headerSection(profile)
                    
                    VStack(spacing: Spacing.s12) {
                        menuItem(icon: "person.crop.rectangle.fill", title: "Professional Info", subtitle: "Specialties, bio, and education") {
                            viewModel.navigateToPersonalInfo()
                        }
                        menuItem(icon: "doc.plaintext.fill", title: "Documents", subtitle: "Verified", showBadge: true) {
                            viewModel.navigateToDocuments()
                        }
                        menuItem(icon: "gearshape.fill", title: "Settings", subtitle: "App preferences & privacy") {
                            viewModel.navigateToSettings()
                        }
                        menuItem(icon: "text.bubble.fill", title: "Reviews", subtitle: "\(profile.totalReviews ?? 0) patient testimonials") {
                            viewModel.navigateToReviews()
                        }
                        menuItem(icon: "wallet.pass.fill", title: "Wallet", subtitle: "payment method")
                        menuItem(icon: "questionmark.circle.fill", title: "Support", subtitle: "Help center and live chat")
                    }
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .font(.headline)
                        .foregroundColor(.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.s16)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.r12)
                                .stroke(Color.error.opacity(0.3), lineWidth: 1)
                                .background(Color.surface.cornerRadius(Radius.r12))
                        )
                    }
                    .padding(.top, Spacing.s16)
                    
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.hint)
                        .padding(.bottom, Spacing.s24)
                }
            }
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s16)
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .onAppear {
            viewModel.loadProfile()
        }
        .onChange(of: selectedImageItem) { newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.updateProfileImage(data: data)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func headerSection(_ profile: ProfileEntity) -> some View {
        VStack(spacing: Spacing.s16) {
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = profile.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.surfaceVariant
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 3))
                } else {
                    Circle().fill(Color.surfaceVariant)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.brandPrimary)
                        )
                        .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 3))
                }
                
                if viewModel.isUploadingImage {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 100, height: 100)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .onPrimary))
                    }
                }
            }
            
            VStack(spacing: Spacing.s4) {
                Text(profile.fullName)
                    .font(.title2).bold()
                    .foregroundColor(.primaryFont)
                
                HStack(spacing: Spacing.s4) {
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(.brandPrimary)
                        .font(.caption)
                    Text(profile.specialization ?? "General")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.s16)
    }
    
    @ViewBuilder
    private func menuItem(icon: String, title: String, subtitle: String, showBadge: Bool = false, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.s16) {
                Image(systemName: icon)
                    .carelyText(style: .bodyRegular)
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.primaryContainer.opacity(0.5))
                    .clipShape(RoundedRectangle.carely(Radius.r16))

                VStack(alignment: .leading, spacing: Spacing.s4) {
                    HStack {
                        Text(title)
                            .carelyText(style: .bodyRegular, weight: .semiBold)
                            .foregroundColor(.primaryFont)
                        if showBadge {
                            Circle()
                                .fill(Color.success)
                                .frame(width: 8, height: 8)
                        }
                    }
                    Text(subtitle)
                        .carelyText(style: .caption)
                        .foregroundColor(.secondaryFont)
                }
                
                Spacer(minLength: Spacing.s8)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.hint)
            }
            .padding(Spacing.s16)
            .background(Color.surface)
            .clipShape(RoundedRectangle.carely(Radius.r20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Skeleton View

public struct ProfileSkeletonView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Spacing.s24) {
            // Header Section Skeleton
            VStack(spacing: Spacing.s12) {
                EtmaenSkeletonCircle(size: 88)

                EtmaenSkeletonRect(width: 150, height: 20, radius: Radius.r8)
                EtmaenSkeletonRect(width: 100, height: 14, radius: Radius.r8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.s16)

            // Menu Items Skeleton
            VStack(spacing: Spacing.s12) {
                ForEach(0..<6, id: \.self) { _ in
                    HStack(spacing: Spacing.s16) {
                        EtmaenSkeletonCircle(size: 40)

                        VStack(alignment: .leading, spacing: Spacing.s4) {
                            EtmaenSkeletonRect(width: 130, height: 16, radius: Radius.r8)
                            EtmaenSkeletonRect(width: 180, height: 12, radius: Radius.r8)
                        }

                        Spacer()

                        EtmaenSkeletonCircle(size: 16)
                    }
                    .padding(Spacing.s16)
                    .background(Color.surface)
                    .cornerRadius(Radius.r16)
                }
            }
        }
        .padding(.horizontal, Spacing.s16)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProfileViewModel(
            getProfileUseCase: MockGetProfileUseCase(),
            updateProfileImageUseCase: MockUpdateProfileImageUseCase(),
            updateDocumentUseCase: MockUpdateDocumentUseCase(),
            logoutUseCase: MockLogoutUseCase(),
            tokenStore: MockTokenStore(),
            coordinator: ProfileCoordinator()
        )
        
        viewModel.profile = ProfileEntity(
            id: "1",
            firstName: "Nurse",
            lastName: "Mona",
            profileImageUrl: nil,
            specialization: "General",
            ratingAvg: 4.8,
            totalReviews: 120,
            yearsOfExperience: 5,
            bio: "Mock bio",
            services: [],
            nationalIdFrontUrl: nil,
            nationalIdBackUrl: nil,
            licenseImageUrl: nil,
            professionalCertificateUrl: nil,
            verificationStatus: "Verified"
        )
        
        return ProfileView(viewModel: viewModel)
    }
}

class MockGetProfileUseCase: GetProfileUseCaseProtocol {
    func execute(id: String) async throws -> ProfileEntity {
        return ProfileEntity(id: "1", firstName: "Nurse", lastName: "Mona", profileImageUrl: nil, specialization: "General", ratingAvg: 4.8, totalReviews: 120, yearsOfExperience: 5, bio: "Mock bio", services: [], nationalIdFrontUrl: nil, nationalIdBackUrl: nil, licenseImageUrl: nil, professionalCertificateUrl: nil, verificationStatus: "Verified")
    }
}
class MockUpdateProfileImageUseCase: UpdateProfileImageUseCaseProtocol {
    func execute(id: String, imageData: Data) async throws -> ProfileEntity {
        return ProfileEntity(id: "1", firstName: "Nurse", lastName: "Mona", profileImageUrl: nil, specialization: "General", ratingAvg: 4.8, totalReviews: 120, yearsOfExperience: 5, bio: "Mock bio", services: [], nationalIdFrontUrl: nil, nationalIdBackUrl: nil, licenseImageUrl: nil, professionalCertificateUrl: nil, verificationStatus: "Verified")
    }
}
class MockUpdateDocumentUseCase: UpdateDocumentUseCaseProtocol {
    func execute(id: String, type: DocumentUploadType, imageData: Data) async throws -> ProfileEntity {
        return ProfileEntity(id: "1", firstName: "Nurse", lastName: "Mona", profileImageUrl: nil, specialization: "General", ratingAvg: 4.8, totalReviews: 120, yearsOfExperience: 5, bio: "Mock bio", services: [], nationalIdFrontUrl: nil, nationalIdBackUrl: nil, licenseImageUrl: nil, professionalCertificateUrl: nil, verificationStatus: "Verified")
    }
}
class MockLogoutUseCase: LogoutUseCaseProtocol {
    func execute() async throws {}
}
class MockTokenStore: TokenStoring {
    func saveTokens(access: String, refresh: String) {}
    func getAccessToken() -> String? { return nil }
    func getRefreshToken() -> String? { return nil }
    func clearTokens() {}
    func saveNurseId(_ id: String) {}
    func getNurseId() -> String? { return "1" }
    func clearNurseId() {}
}
#endif
