//
//  NurseService.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

protocol NurseServiceProtocol {
    func getNurse(id: String) async throws -> NurseResponseDTO
}

final class NurseServiceImpl: NurseServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func getNurse(id: String) async throws -> NurseResponseDTO {
        return try await networkClient.request(NurseEndpoint.getNurse(id: id))
    }
}
