//
//  NurseEntity.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

/// Domain model representing a nurse's profile and verification status.
struct NurseEntity {
    let id: String
    let firstName: String?
    let lastName: String?
    let verificationStatus: ApplicationStatus
    let rejectionReason: String?
    let rejectionDetails: NurseRejectionDetails?
}

struct NurseRejectionDetails {
    let overallReason: String?
    let failedSteps: [NurseFailedStep]
}

struct NurseFailedStep {
    let step: String
    let reason: String
}
