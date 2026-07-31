//
//  LoginUseCase.swift
//  EnayaProvider
//
//  Created by Mona Zarea on 30/07/2026.
//


import Foundation

protocol LoginUseCaseProtocol {
    func execute(phoneNumber: String) async throws -> DevOTPResponse
}

struct LoginUseCase: LoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(phoneNumber: String) async throws -> DevOTPResponse {
        try await repository.login(phoneNumber: phoneNumber)
        return try await repository.requestOTPDev(phoneNumber: phoneNumber)
    }
}

