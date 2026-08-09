//
//  OfferRoute.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//


// MARK: - OfferRoute.swift
import Foundation

enum OfferRoute: Hashable {
    case details
    case chat(patientName: String, imageUrl: String?, phone: String)
}

    
  
