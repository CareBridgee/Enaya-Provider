//
//  ProfileSetupRepositoryImpl.swift
//  Carely
//
//  Created by Mohamed Ayman on 19/07/2026.
//
import Foundation

final class ProfileSetupRepositoryImpl: ProfileSetupRepositoryProtocol {
    private let simulatedDelayNanoseconds: UInt64 = 1_200_000_000

    func submitApplication(_ data: ProfileSetupData) async throws {
        try await Task.sleep(nanoseconds: simulatedDelayNanoseconds)
    }
}
