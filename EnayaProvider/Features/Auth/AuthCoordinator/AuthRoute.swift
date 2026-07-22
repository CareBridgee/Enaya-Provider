//
//  AuthRoute.swift
//  Carely
//
//  Created by Mohamed Ayman on 16/07/2026.
//

import Foundation

enum AuthRoute: Hashable {
    case PhoneNumber
      case OTPVerification(phoneNumber: String)
}
