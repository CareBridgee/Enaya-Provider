//
//  ProfileRepositoryProtocol.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func getProfile(id: String) async throws -> ProfileEntity
    func updateProfile(id: String, bio: String, specialization: String, yearsOfExperience: Int) async throws -> ProfileEntity
    func updateProfileImage(id: String, imageData: Data) async throws -> ProfileEntity
    func updateDocument(id: String, type: DocumentUploadType, imageData: Data) async throws -> ProfileEntity
    func getReviews(id: String, page: Int, size: Int) async throws -> PaginatedReviewsEntity
}
