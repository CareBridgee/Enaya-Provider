//
//  ObserveSocketErrorsUseCase.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 09/08/2026.
//


struct ObserveSocketErrorsUseCase {
        let repository: HomeRepositoryProtocol
        func execute() -> AsyncStream<SocketErrorPayload> {
            repository.observeSocketErrors()
        }
    }