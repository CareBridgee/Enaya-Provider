//
//  ProfileReviewsViewModel.swift
//  EnayaProvider
//
//  Created by AI.
//

import Foundation

@MainActor
final class ProfileReviewsViewModel: ObservableObject {
    @Published var reviews: [ReviewEntity] = []
    @Published var isLoading = false
    @Published var isFetchingMore = false
    @Published var errorMessage: String?
    
    private let nurseId: String
    private let getReviewsUseCase: GetNurseReviewsUseCaseProtocol
    
    // Pagination state
    private var currentPage = 0
    private let pageSize = 20
    private var isLastPage = false
    
    // Mocking filter state for UI
    @Published var selectedFilter: String = "Most Recent"
    let availableFilters = ["Most Recent", "Top Rated", "Critical", "With Photos"]
    
    init(nurseId: String, getReviewsUseCase: GetNurseReviewsUseCaseProtocol) {
        self.nurseId = nurseId
        self.getReviewsUseCase = getReviewsUseCase
    }
    
    func fetchReviews(reset: Bool = false) {
        if reset {
            currentPage = 0
            reviews = []
            isLastPage = false
        }
        
        guard !isLastPage else { return }
        guard !isLoading && !isFetchingMore else { return }
        
        if reset {
            isLoading = true
        } else {
            isFetchingMore = true
        }
        errorMessage = nil
        
        Task {
            do {
                let paginatedResult = try await getReviewsUseCase.execute(id: nurseId, page: currentPage, size: pageSize)
                
                // If it's a reset, replace. Otherwise append.
                if reset {
                    self.reviews = paginatedResult.reviews
                } else {
                    self.reviews.append(contentsOf: paginatedResult.reviews)
                }
                
                self.currentPage = paginatedResult.pageNumber + 1
                self.isLastPage = paginatedResult.isLastPage
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
            self.isFetchingMore = false
        }
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = filter
        // In a real app, this would trigger a new fetch with a sort/filter parameter
        // For now, we'll just mock the state change
        // fetchReviews(reset: true)
    }
}
