//
//  DocumentUploadCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import SwiftUI
import UniformTypeIdentifiers

struct DocumentUploadCard: View {
    let title: String
    let subtitle: String
    @Binding var document: UploadedDocument?

    @State private var isImporterPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack(spacing: Spacing.s12) {
                ZStack {
                    Circle()
                        .fill(Color.mintSurface)
                        .frame(width: Spacing.s32, height: Spacing.s32)
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.brandPrimary)
                }

                VStack(alignment: .leading, spacing: Spacing.s2) {
                    Text(title)
                        .carelyText(style: .bodyRegular, weight: .semiBold)
                        .foregroundColor(.primaryFont)
                    Text(subtitle)
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.secondaryFont)
                }

                Spacer(minLength: .zero)

                if document != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.success)
                }
            }

            uploadArea
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf, .png, .jpeg],
            onCompletion: handleImport
        )
    }

    @ViewBuilder
    private var uploadArea: some View {
        if let document {
            HStack(spacing: Spacing.s8) {
                Image(systemName: "doc.fill")
                    .foregroundColor(.brandPrimary)
                Text(document.fileName)
                    .carelyText(style: .bodySmall, weight: .medium)
                    .foregroundColor(.primaryFont)
                    .lineLimit(1)
                Spacer()
                Button(action: { self.document = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.hint)
                }
            }
            .padding(Spacing.s12)
            .background(Color.surfaceVariant)
            .clipShape(RoundedRectangle.carely(Radius.r12))
        } else {
            Button(action: { isImporterPresented = true }) {
                VStack(spacing: Spacing.s4) {
                    Image(systemName: "icloud.and.arrow.up")
                        .foregroundColor(.brandPrimary)
                    Text("Click to upload or drag & drop")
                        .carelyText(style: .bodySmall, weight: .medium)
                        .foregroundColor(.brandPrimary)
                    Text("PDF, JPG or PNG (max 10MB)")
                        .carelyText(style: .caption, weight: .regular)
                        .foregroundColor(.hint)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.s16)
                .overlay(
                    RoundedRectangle.carely(Radius.r12)
                        .strokeBorder(Color.divider, style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
            }
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        guard let url = try? result.get() else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        document = UploadedDocument(fileName: url.lastPathComponent, data: data)
    }
}
