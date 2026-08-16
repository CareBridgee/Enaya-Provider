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
    
    @State private var documentToView: DocumentItem?
    @State private var showErrorAlert = false
    
    struct DocumentItem: Identifiable {
        let id = UUID()
        let url: String
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(
                title: "Documents",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                VStack(spacing: Spacing.s20) {
                    
                    // Info Banner
                    infoBanner
                        .padding(.top, Spacing.s16)
                    
                    // National ID Card
                    documentCard(
                        iconName: "person.text.rectangle",
                        title: "National ID",
                        isUploaded: profile.nationalIdFrontUrl != nil && profile.nationalIdBackUrl != nil,
                        isVerified: profile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "Front Side", url: profile.nationalIdFrontUrl, type: .nationalIdFront),
                            DocumentRow(label: "Back Side", url: profile.nationalIdBackUrl, type: .nationalIdBack)
                        ]
                    )
                    
                    // Nursing License Card
                    documentCard(
                        iconName: "cross.case",
                        title: "Nursing License",
                        isUploaded: profile.licenseImageUrl != nil,
                        isVerified: profile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "License Document", url: profile.licenseImageUrl, type: .licenseImage)
                        ]
                    )
                    
                    // Professional Certificate Card
                    documentCard(
                        iconName: "doc.text",
                        title: "Professional Certificate",
                        isUploaded: profile.professionalCertificateUrl != nil,
                        isVerified: profile.verificationStatus == "Verified",
                        rows: [
                            DocumentRow(label: "Certificate Document", url: profile.professionalCertificateUrl, type: .professionalCertificate)
                        ]
                    )
                }
                .padding(.horizontal, Spacing.s20)
                .padding(.bottom, Spacing.s40)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .fullScreenCover(item: $documentToView) { item in
            DocumentViewerView(url: item.url, isPresented: Binding(
                get: { documentToView != nil },
                set: { if !$0 { documentToView = nil } }
            ))
        }
        .alert("Upload Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred while uploading the document.")
        }
        .overlay {
            if viewModel.isUploadingDocument {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .onPrimary))
                        .scaleEffect(1.5)
                }
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
                    .foregroundColor(Color.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.successContainer)
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
        .background(Color.surface)
        .cornerRadius(Radius.r16)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.r16)
                .stroke(Color.divider, lineWidth: 1)
        )
    }
    
    private var infoBanner: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.onPrimary)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("Why is my document pending?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.onPrimary)
                
                Text("Our clinical review team typically verifies documents within 24-48 business hours. You'll receive a notification once the status changes.")
                    .font(.system(size: 14))
                    .foregroundColor(.onPrimary.opacity(0.9))
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
            guard let newItem = newItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            onUpload(data, row.type)
                        }
                    } else {
                        await MainActor.run {
                            onError("Could not load the selected image.")
                        }
                    }
                } catch {
                    await MainActor.run {
                        onError("Error loading image: \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    selectedItem = nil
                }
            }
        }
    }
}
