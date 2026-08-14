//
//  ProfileDocumentsView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI
import PhotosUI

struct ProfileDocumentsView: View {
    let profile: ProfileEntity
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var viewingImageUrl: String?
    @State private var documentToView: DocumentItem?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    struct DocumentItem: Identifiable {
        let id = UUID()
        let url: String
    }
    
    private var currentProfile: ProfileEntity {
        viewModel.profile ?? profile
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "NurseConnect",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Professional Documents")
                            .carelyText(style: .heading2, weight: .bold)
                            .foregroundColor(.primaryFont)
                        
                        Text("Manage your credentials and certifications for verification.")
                            .carelyText(style: .bodyRegular, weight: .regular)
                            .foregroundColor(.secondaryFont)
                    }
                    .padding(.top, Spacing.s16)

                    // National ID Card
                    documentCard(
                        iconName: "person.text.rectangle.fill",
                        title: "National ID",
                        isUploaded: currentProfile.nationalIdFrontUrl != nil && currentProfile.nationalIdBackUrl != nil,
                        isVerified: currentProfile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "Front side", url: currentProfile.nationalIdFrontUrl, type: .nationalIdFront),
                            DocumentRow(label: "Back side", url: currentProfile.nationalIdBackUrl, type: .nationalIdBack)
                        ]
                    )
                    
                    // Nursing License
                    documentCard(
                        iconName: "doc.text.fill",
                        title: "Nursing License",
                        isUploaded: currentProfile.licenseImageUrl != nil,
                        isVerified: currentProfile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "Nursing License", url: currentProfile.licenseImageUrl, type: .licenseImage)
                        ]
                    )
                    
                    // Professional Certificate
                    documentCard(
                        iconName: "medal.fill",
                        title: "Professional Certificate",
                        isUploaded: currentProfile.professionalCertificateUrl != nil,
                        isVerified: currentProfile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "Professional Certificate", url: currentProfile.professionalCertificateUrl, type: .professionalCertificate)
                        ]
                    )
                    
                    // Info Banner
                    infoBanner
                        .padding(.bottom, 80)
                }
                .padding(.horizontal, Spacing.s20)
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay {
            if viewModel.isUploadingDocument {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: Spacing.s16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .brandPrimary))
                        Text("Uploading Document...")
                            .carelyText(style: .bodyLarge, weight: .bold)
                            .foregroundColor(.primaryFont)
                    }
                    .padding(Spacing.s24)
                    .background(Color.white)
                    .cornerRadius(Radius.r16)
                    .shadow(radius: 10)
                }
            }
        }
        .onChange(of: viewModel.isUploadingDocument) { isUploading in
            if !isUploading {
                if viewModel.errorMessage != nil {
                    showErrorAlert = true
                } else {
                    showSuccessAlert = true
                }
            }
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your document has been updated successfully and is pending review.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .fullScreenCover(item: $documentToView) { item in
            DocumentViewerView(url: item.url, isPresented: Binding(
                get: { documentToView != nil },
                set: { if !$0 { documentToView = nil } }
            ))
        }
        .onAppear {
            if viewModel.profile == nil {
                viewModel.profile = profile
            }
        }
    }
    
    // MARK: - Subviews
    
    struct DocumentRow {
        let label: String
        let url: String?
        let type: DocumentUploadType
    }
    
    @ViewBuilder
    private func documentCard(iconName: String, title: String, isUploaded: Bool, isVerified: Bool, rows: [DocumentRow]) -> some View {
        VStack(spacing: Spacing.s16) {
            // Header
            HStack(spacing: Spacing.s12) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.r12)
                        .fill(Color.mintSurface)
                        .frame(width: 48, height: 48)
                    Image(systemName: iconName)
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .carelyText(style: .bodyLarge, weight: .bold)
                        .foregroundColor(.primaryFont)
                    Text(isUploaded ? "Uploaded" : "Not Uploaded")
                        .carelyText(style: .bodySmall, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }
                
                Spacer()
                
                if isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Verified")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Rows
            VStack(spacing: Spacing.s12) {
                ForEach(rows, id: \.type.rawValue) { row in
                    DocumentRowView(
                        row: row,
                        onView: { url in
                            documentToView = DocumentItem(url: url)
                        },
                        onUpload: { data, type in
                            viewModel.uploadDocument(type: type, data: data)
                        },
                        onError: { message in
                            viewModel.errorMessage = message
                            showErrorAlert = true
                        }
                    )
                }
            }
        }
        .padding(Spacing.s16)
        .background(Color.white)
        .cornerRadius(Radius.r16)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.r16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var infoBanner: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("Why is my document pending?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Our clinical review team typically verifies documents within 24-48 business hours. You'll receive a notification once the status changes.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.s16)
        .background(Color.brandPrimary)
        .cornerRadius(Radius.r16)
    }
}

// MARK: - Document Viewer View
struct DocumentViewerView: View {
    let url: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .padding()
                    }
                }
                
                Spacer()
                
                if let urlString = url, let imageURL = URL(string: urlString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Text("Failed to load document")
                                .foregroundColor(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("No document available")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Document Row View
struct DocumentRowView: View {
    let row: ProfileDocumentsView.DocumentRow
    let onView: (String) -> Void
    let onUpload: (Data, DocumentUploadType) -> Void
    let onError: (String) -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        HStack {
            Text(row.label)
                .carelyText(style: .bodyRegular, weight: .regular)
                .foregroundColor(.primaryFont)
            
            Spacer()
            
            HStack(spacing: Spacing.s16) {
                if let url = row.url {
                    Button("View") {
                        onView(url)
                    }
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 14, weight: .medium))
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Edit")
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 14, weight: .medium))
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            print("DocumentRowView: onChange fired. newItem is \(newItem != nil ? "NOT nil" : "nil")")
            guard let newItem = newItem else { return }
            
            Task {
                print("DocumentRowView: Task started for loading image.")
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        print("DocumentRowView: Successfully loaded data. Size: \(data.count) bytes.")
                        await MainActor.run {
                            onUpload(data, row.type)
                        }
                    } else {
                        print("DocumentRowView: loadTransferable returned nil data.")
                        await MainActor.run {
                            onError("Could not load the selected image.")
                        }
                    }
                } catch {
                    print("DocumentRowView: loadTransferable threw error: \(error)")
                    await MainActor.run {
                        onError("Error loading image: \(error.localizedDescription)")
                    }
                }
                
                // Reset selection after processing so the picker works if we select the exact same image again
                await MainActor.run {
                    print("DocumentRowView: Resetting selectedItem to nil.")
                    selectedItem = nil
                }
            }
        }
    }
}
