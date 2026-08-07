//
//  ApplicationStatus.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//



import Foundation

enum ApplicationStatus: String, Equatable {
    case incomplete  = "INCOMPLETE"
    case underReview = "UNDER_REVIEW"
    case approved    = "APPROVED"
    case rejected    = "REJECTED"
}
