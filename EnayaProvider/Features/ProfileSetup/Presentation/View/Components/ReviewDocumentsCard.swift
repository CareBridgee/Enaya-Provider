//
//  ReviewDocumentsCard.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 26/07/2026.
//


import SwiftUI

struct ReviewDocumentsCard: View {
    @ObservedObject var viewModel: ReviewApplicationViewModel

    var body: some View {
        ReviewSectionCard(
            title: "Documents",
            icon: "doc.text",
            onEdit: viewModel.editProfessionalInfoTapped
        ) {
            VStack(spacing: Spacing.s12) {
                if let backID = viewModel.data.professionalInfo.nationalIdBack {
                    ReviewDocumentRow(icon: icon(for: backID.fileName), name: backID.fileName)
                }
                if let frontID = viewModel.data.professionalInfo.nationalIdFront {
                    ReviewDocumentRow(icon: icon(for: frontID.fileName), name: frontID.fileName)
                }
                if let license = viewModel.data.professionalInfo.nursingLicenseDocument {
                    ReviewDocumentRow(icon: icon(for: license.fileName), name: license.fileName)
                }
                if let certificate = viewModel.data.professionalInfo.professionalCertificateDocument {
                    ReviewDocumentRow(icon: icon(for: certificate.fileName), name: certificate.fileName)
                }
            }
        }
    }
    
    private func icon(for fileName: String) -> String {
        let lowercasedName = fileName.lowercased()
        if lowercasedName.hasSuffix(".jpg") ||
           lowercasedName.hasSuffix(".jpeg") ||
           lowercasedName.hasSuffix(".png") ||
           lowercasedName.hasSuffix(".heic") {
            return "photo.fill"
        } else {
            return "doc.text.fill"
        }
    }
}
