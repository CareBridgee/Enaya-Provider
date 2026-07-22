//
//  CareService.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

enum CareService: String, CaseIterable, Identifiable {
    case injection, ivTherapy, bloodCollection, woundDressing
    case catheterCare, elderlyCare, childCare, postSurgeryCare
    case maternalCare, physiotherapy, ecgService, homeAssessment

    var id: Self { self }

    var title: String {
        switch self {
        case .injection: return "Injection"
        case .ivTherapy: return "IV Therapy"
        case .bloodCollection: return "Blood Collection"
        case .woundDressing: return "Wound Dressing"
        case .catheterCare: return "Catheter Care"
        case .elderlyCare: return "Elderly Care"
        case .childCare: return "Child Care"
        case .postSurgeryCare: return "Post-Surgery Care"
        case .maternalCare: return "Maternal Care"
        case .physiotherapy: return "Physiotherapy"
        case .ecgService: return "ECG Service"
        case .homeAssessment: return "Home Assessment"
        }
    }

    var icon: String {
        switch self {
        case .injection: return "syringe"
        case .ivTherapy: return "drop.fill"
        case .bloodCollection: return "testtube.2"
        case .woundDressing: return "bandage.fill"
        case .catheterCare: return "cross.case.fill"
        case .elderlyCare: return "figure.walk"
        case .childCare: return "figure.child"
        case .postSurgeryCare: return "bandage"
        case .maternalCare: return "figure.and.child.holdinghands"
        case .physiotherapy: return "figure.strengthtraining.traditional"
        case .ecgService: return "waveform.path.ecg"
        case .homeAssessment: return "house.fill"
        }
    }
}

struct ProvidedServices {
    var selectedServices: Set<CareService> = []
}