//
//  HomeError.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation

enum HomeError: LocalizedError {
    case priceOutOfRange(min: Decimal, max: Decimal)
    case requestNotFound

    var errorDescription: String? {
        switch self {
        case .priceOutOfRange(let min, let max):
            return "Price must be between \(min) and \(max)."
        case .requestNotFound:
            return "This request is no longer available."
        }
    }
}