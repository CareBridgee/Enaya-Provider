//
//  SetAvailabilityUseCaseProtocol.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import Foundation


struct ToggleAvailabilityUseCase {
    let repo: HomeRepositoryProtocol
    func execute(isOnline: Bool) async throws { try await repo.setAvailability(isOnline: isOnline) }
}
