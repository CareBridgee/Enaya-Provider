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
                    ProgressView()
                        .padding(.top, 50)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if let profile = viewModel.profile {
                    headerSection(profile)
                    
                    VStack(spacing: Spacing.s12) {
                        menuItem(icon: "person.crop.rectangle", title: "Professional Info", subtitle: "Specialties, bio, and education") {
                            viewModel.navigateToPersonalInfo()
                        }
                        menuItem(icon: "doc.plaintext", title: "Documents", subtitle: "Verified", showBadge: true) {
                            viewModel.navigateToDocuments()
                        }
                        menuItem(icon: "calendar", title: "Availability Settings", subtitle: "Working hours & block dates")
                        menuItem(icon: "text.bubble", title: "Reviews", subtitle: "\(profile.totalReviews ?? 0) patient testimonials") {
                            viewModel.navigateToReviews()
                        }
                        menuItem(icon: "wallet.pass", title: "Wallet", subtitle: "payment method")
                        menuItem(icon: "questionmark.circle", title: "Support", subtitle: "Help center and live chat")
                    }
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.s16)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.r12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                .background(Color.white.cornerRadius(Radius.r12))
                        )
                    }
                    .padding(.top, Spacing.s16)
                    
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, Spacing.s24)
                }
            }
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s16)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    if let imageUrl = viewModel.profile?.profileImageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Circle().fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                    }
                    
                    Text(viewModel.profile?.firstName ?? "Profile")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.navigateToSettings()
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.brandPrimary)
                }
            }
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
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.brandPrimary, lineWidth: 3))
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                
                // Edit Pin
                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.brandPrimary)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .offset(x: 5, y: -5) // Adjusted offset to be more up
                
                if viewModel.isUploadingImage {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 100, height: 100)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                

            }
            
            VStack(spacing: Spacing.s4) {
                Text(profile.fullName)
                    .font(.title2).bold()
                
                HStack {
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(.brandPrimary)
                    Text(profile.specialization ?? "General")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
        }
        .padding(Spacing.s24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(Radius.r24)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    @ViewBuilder
    private func menuItem(icon: String, title: String, subtitle: String, showBadge: Bool = false, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.s16) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.r12)
                        .fill(Color.mintSurface)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primaryFont)
                        if showBadge {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryFont)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Radius.r16)
        }
        .buttonStyle(PlainButtonStyle())
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
        
        // Mock data to render immediately
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
