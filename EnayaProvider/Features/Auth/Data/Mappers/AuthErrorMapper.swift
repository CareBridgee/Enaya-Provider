//
//  file.swift
//  Carely
//
//  Created by Mona Zarea on 15/07/2026.
//

import Foundation

extension Error {
    func toAuthError() -> AuthError {
        guard let networkError = self as? NetworkError else {
            return .unknown
        }
        
        switch networkError {
            
        case .noInternetConnection, .timeout:
            return .network
            
        case .unauthorized:
            return .invalidOTP
            
        case .server(let statusCode, _):
            switch statusCode {
            case 409:
                return .conflict
            case 410, 422:
                return .otpExpired
            case 500...599:
                return .network
            default:
                return .unknown
            }
            
        case .decodingFailed, .cancelled, .unknown, .invalidURL, .sessionExpired:
            return .unknown
        }
    }
}
