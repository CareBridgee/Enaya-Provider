//
//  EarningsHistoryViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 02/08/2026.
//

import Foundation

enum EarningsTimeFilter {
    case all
    case thisMonth
}

enum EarningsSortOption: String, CaseIterable, Identifiable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case highestPrice = "Highest Price"
    case lowestPrice = "Lowest Price"

    var id: String { rawValue }
}

@MainActor
final class EarningsHistoryViewModel: ObservableObject {
    /// Filtered + sorted items shown in the list.
    @Published private(set) var items: [NurseServiceRequestHistoryItem] = []
    @Published private(set) var totalEarnings: Decimal = 0
    @Published private(set) var jobsCount: Int = 0
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published private(set) var selectedService: String?
    @Published private(set) var timeFilter: EarningsTimeFilter = .all
    @Published private(set) var sortOption: EarningsSortOption = .newest

    /// All service names present in the current history, for the service filter menu.
    var availableServices: [String] {
        Array(Set(allItems.map(\.serviceName))).sorted()
    }

    var isFiltering: Bool {
        selectedService != nil || timeFilter != .all
    }

    /// Unfiltered data as fetched from the server. `items` is derived from this.
    private var allItems: [NurseServiceRequestHistoryItem] = []

    private let coordinator: EarningsCoordinator
    private let historyUseCase: FetchNurseHistoryUseCase

    init(coordinator: EarningsCoordinator, historyUseCase: FetchNurseHistoryUseCase) {
        self.coordinator = coordinator
        self.historyUseCase = historyUseCase
    }

    func loadData() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let history = try await historyUseCase.execute()
                allItems = history
                jobsCount = history.count
                
                // Calculate exact nurse payout for total earnings
                totalEarnings = history
                    .filter { $0.status == .completed }
                    .reduce(Decimal(0)) { partialResult, item in
                        let rawPrice = NSDecimalNumber(decimal: item.estimatedPrice ?? 0).doubleValue
                        let appFee = min(rawPrice * 0.20, 120.0)
                        return partialResult + Decimal(rawPrice - appFee)
                    }
                applyFilters()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func retryTapped() {
        loadData()
    }

    func viewPayoutsTapped() {
        coordinator.goToPayouts()
    }

    // MARK: - Filtering & sorting

    func selectService(_ service: String?) {
        selectedService = service
        applyFilters()
    }

    func setTimeFilter(_ filter: EarningsTimeFilter) {
        timeFilter = filter
        applyFilters()
    }

    func setSortOption(_ option: EarningsSortOption) {
        sortOption = option
        applyFilters()
    }

    func clearFilters() {
        selectedService = nil
        timeFilter = .all
        applyFilters()
    }

    private func applyFilters() {
        var result = allItems

        if let selectedService {
            result = result.filter { $0.serviceName == selectedService }
        }

        if timeFilter == .thisMonth {
            let calendar = Calendar.current
            let now = Date()
            result = result.filter { item in
                guard let date = item.createdAt else { return false }
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
                    && calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }

        switch sortOption {
        case .newest:
            result.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .oldest:
            result.sort { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
        case .highestPrice:
            result.sort { ($0.estimatedPrice ?? 0) > ($1.estimatedPrice ?? 0) }
        case .lowestPrice:
            result.sort { ($0.estimatedPrice ?? 0) < ($1.estimatedPrice ?? 0) }
        }

        items = result
    }
}
