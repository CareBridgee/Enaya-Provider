//
//  NurseRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

protocol NurseRepositoryProtocol {
    func getNurse(id: String) async throws -> NurseEntity
}
