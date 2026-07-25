//
//  DocumentRejectedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class DocumentRejectedViewModel: ObservableObject {
    let rejection: DocumentRejection

    private let onUploadAgain: () -> Void
    private let onContactSupport: () -> Void

    init(
        rejection: DocumentRejection,
        onUploadAgain: @escaping () -> Void,
        onContactSupport: @escaping () -> Void = {}
    ) {
        self.rejection = rejection
        self.onUploadAgain = onUploadAgain
        self.onContactSupport = onContactSupport
    }

    func uploadAgainTapped() { onUploadAgain() }
    func contactSupportTapped() { onContactSupport() }
}