

import Foundation

@MainActor
final class ProfileReviewsViewModel: ObservableObject {
    @Published var allReviews: [ReviewEntity] = []
    @Published var filteredReviews: [ReviewEntity] = []
    
    @Published var isLoading = false
    @Published var isFetchingMore = false
    @Published var errorMessage: String?
    
    // Dynamically calculated rating distribution
    @Published var ratingPercentages: [Int: Int] = [5: 0, 4: 0, 3: 0, 2: 0, 1: 0]
    
    private let nurseId: String
    private let getReviewsUseCase: GetNurseReviewsUseCaseProtocol
    private let fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol // 👈 Injected
    
    // Pagination state
    private var currentPage = 0
    private let pageSize = 20
    @Published var isLastPage = false
    
    @Published var selectedFilter: String = "Most Recent"
    let availableFilters = ["Most Recent", "Top Rated", "Critical"]
    
    init(
        nurseId: String,
        getReviewsUseCase: GetNurseReviewsUseCaseProtocol,
        fetchProfileUseCase: FetchServiceRequestProfileUseCaseProtocol
    ) {
        self.nurseId = nurseId
        self.getReviewsUseCase = getReviewsUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
    }
    
    func fetchReviews(reset: Bool = false) {
        if reset {
            currentPage = 0
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
                var fetchedReviews = paginatedResult.reviews
                
                // ⚡️ FAST CONCURRENT FETCHING: Fetch all non-anonymous patient profiles simultaneously
                await withTaskGroup(of: (Int, String, String?).self) { group in
                    for (index, review) in fetchedReviews.enumerated() {
                        if !review.isAnonymous {
                            group.addTask {
                                do {
                                    let profileResponse = try await self.fetchProfileUseCase.execute(serviceRequestId: review.serviceRequestId)
                                    let fullName = "\(profileResponse.patient.firstName) \(profileResponse.patient.lastName)".trimmingCharacters(in: .whitespaces)
                                    return (index, fullName, profileResponse.patient.profileImageUrl)
                                } catch {
                                    // Fallback to "Patient" if the profile fails to load
                                    return (index, "Patient", nil)
                                }
                            }
                        }
                    }
                    
                    // Inject the fetched real names and images back into the array
                    for await (index, realName, imageUrl) in group {
                        fetchedReviews[index].reviewerName = realName
                        fetchedReviews[index].reviewerImageUrl = imageUrl
                    }
                }
                
                // If it's a reset, replace. Otherwise append.
                if reset {
                    self.allReviews = fetchedReviews
                } else {
                    self.allReviews.append(contentsOf: fetchedReviews)
                }
                
                self.currentPage = paginatedResult.pageNumber + 1
                self.isLastPage = paginatedResult.isLastPage
                
                self.calculatePercentages()
                self.applyFilter()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
            self.isFetchingMore = false
        }
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = filter
        applyFilter()
    }
    
    private func applyFilter() {
        switch selectedFilter {
        case "Most Recent":
            filteredReviews = allReviews.sorted { $0.createdAt > $1.createdAt }
        case "Top Rated":
            filteredReviews = allReviews.sorted { $0.rating > $1.rating }
        case "Critical":
            filteredReviews = allReviews.sorted { $0.rating < $1.rating }
        default:
            filteredReviews = allReviews
        }
    }
    
    private func calculatePercentages() {
        var counts = [5: 0, 4: 0, 3: 0, 2: 0, 1: 0]
        let total = allReviews.count
        
        guard total > 0 else {
            ratingPercentages = counts
            return
        }
        
        for review in allReviews {
            let r = min(max(review.rating, 1), 5)
            counts[r, default: 0] += 1
        }
        
        for (star, count) in counts {
            let percentage = Int((Double(count) / Double(total)) * 100.0)
            ratingPercentages[star] = percentage
        }
    }
}
