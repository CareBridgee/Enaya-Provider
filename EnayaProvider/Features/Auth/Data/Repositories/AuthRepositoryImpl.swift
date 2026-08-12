//
//  RepositoryImpl.swift
//  Carely
//
//  Created by Mona Zarea on 15/07/2026.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login(phoneNumber: String) async throws {
        do {
            try await authService.login(phoneNumber: phoneNumber)
        } catch {
            throw error.toAuthError()
        }
    }
    
    func resendOTP(phoneNumber: String) async throws {
        do {
            try await authService.login(phoneNumber: phoneNumber)
        } catch {
            throw error.toAuthError()
        }
    }
    
    func requestOTPDev(phoneNumber: String) async throws -> DevOTPResponse {
        do {
            return try await authService.requestOTPDev(phoneNumber: phoneNumber)
        } catch {
            throw error.toAuthError()
        }
    }
    
    func verifyOTP(phoneNumber: String, otp: String) async throws -> OTPVerificationEntity {
        do {
            let response = try await authService.verifyOTP(phoneNumber: phoneNumber, otp: otp)
            
            let rawStatus = response.user.nurse?.verificationStatus ?? "INCOMPLETE"
            let actualStatus = ApplicationStatus(rawValue: rawStatus) ?? .incomplete
            
            return OTPVerificationEntity(
                isNewUser: response.user.firstName == "Nurse" && response.user.lastName?.isEmpty == true,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                userId: response.user.id,
                nurseId: response.user.nurse?.id,
                applicationStatus: actualStatus
            )
        } catch {
            throw error.toAuthError()
        }
    }
    
    func getProfile(phoneNumber: String) async throws -> UserDTO {
        do {
            return try await authService.getProfile(phoneNumber: phoneNumber)
        } catch {
            throw error.toAuthError()
        }
    }
    
    func logout(refreshToken: String) async throws {
        do {
            try await authService.logout(refreshToken: refreshToken)
        } catch {
            print("Failed to logout on server: \(error)")
        }
    }
    
    
}
