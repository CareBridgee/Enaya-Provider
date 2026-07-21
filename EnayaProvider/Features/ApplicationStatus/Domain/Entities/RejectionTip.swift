//
//  RejectionTip.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

struct RejectionTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

struct DocumentRejection {
    let documentName: String
    let reason: String
    let tips: [RejectionTip]
}