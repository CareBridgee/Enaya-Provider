//
//  NurseRepositoryImpl.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

final class NurseRepositoryImpl: NurseRepositoryProtocol {
    private let nurseService: NurseServiceProtocol

    init(nurseService: NurseServiceProtocol) {
        self.nurseService = nurseService
    }

    func getNurse(id: String) async throws -> NurseEntity {
        let dto = try await nurseService.getNurse(id: id)
        return map(dto)
    }

    // MARK: - Mapping

    private func map(_ dto: NurseResponseDTO) -> NurseEntity {
        let rawStatus = dto.verificationStatus
        let status = ApplicationStatus(rawValue: rawStatus) ?? .underReview

        let rejectionDetails: NurseRejectionDetails? = dto.rejectionDetails.map { detailsDTO in
            NurseRejectionDetails(
                overallReason: detailsDTO.overallReason,
                failedSteps: detailsDTO.failedSteps?.map {
                    NurseFailedStep(step: $0.step, reason: $0.reason)
                } ?? []
            )
        }

        return NurseEntity(
            id: dto.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            verificationStatus: status,
            rejectionReason: dto.rejectionReason,
            rejectionDetails: rejectionDetails
        )
    }
}
