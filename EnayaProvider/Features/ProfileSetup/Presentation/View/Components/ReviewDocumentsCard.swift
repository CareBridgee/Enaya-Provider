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
                    ReviewDocumentRow(icon: "photo.fill", name: backID.fileName)
                }
                if let frontID = viewModel.data.professionalInfo.nationalIdFront {
                    ReviewDocumentRow(icon: "photo.fill", name: frontID.fileName)
                }
                if let license = viewModel.data.professionalInfo.nursingLicenseDocument {
                    ReviewDocumentRow(icon: "doc.text.fill", name: license.fileName)
                }
                if let certificate = viewModel.data.professionalInfo.professionalCertificateDocument {
                    ReviewDocumentRow(icon: "doc.text.fill", name: certificate.fileName)
                }
            }
        }
    }
}
