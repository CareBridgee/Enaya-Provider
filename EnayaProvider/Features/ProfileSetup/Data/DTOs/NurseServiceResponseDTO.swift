//
//  NurseServiceResponseDTO.swift
//  EnayaProvider
//
//  Created by Mohamed Ayman on 05/08/2026.
//

import Foundation

struct NurseServiceBulkResponseDTO: Decodable {
    let added: [NurseServiceResponseDTO]
}

struct NurseServiceResponseDTO: Decodable {
    let id: String
    let serviceTypeId: String
    let serviceName: String?
    let serviceDescription: String?
    let basePrice: Double?
    let isActive: Bool?
}
