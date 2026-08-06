//
//  CareService.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

struct CareService: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let iconUrl: String?
    let category: String?
    let basePrice: Double?
    
    // Fallback icon logic if no URL or to use local SF symbol by category
    var icon: String {
        guard let cat = category?.lowercased() else { return "star.fill" }
        if cat.contains("injection") || title.lowercased().contains("injection") { return "syringe" }
        if cat.contains("iv") || title.lowercased().contains("iv") { return "drop.fill" }
        if cat.contains("blood") { return "testtube.2" }
        if cat.contains("wound") { return "bandage.fill" }
        if cat.contains("elderly") { return "figure.walk" }
        if cat.contains("child") { return "figure.child" }
        if cat.contains("maternal") { return "figure.and.child.holdinghands" }
        if cat.contains("physio") { return "figure.strengthtraining.traditional" }
        if cat.contains("ecg") { return "waveform.path.ecg" }
        return "cross.case.fill"
    }
}

struct ProvidedServices {
    var availableServices: [CareService] = []
    var selectedServices: Set<CareService> = []
}