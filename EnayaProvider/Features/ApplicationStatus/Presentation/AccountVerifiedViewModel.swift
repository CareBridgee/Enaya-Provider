//
//  AccountVerifiedViewModel.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//


import Foundation

@MainActor
final class AccountVerifiedViewModel: ObservableObject {
    let availableJobsCount: Int
    let networkRewardsCount: Int

    private let onStartJourney: () -> Void
    private let onReviewGuidelines: () -> Void

    init(
        availableJobsCount: Int = 24,
        networkRewardsCount: Int = 12,
        onStartJourney: @escaping () -> Void,
        onReviewGuidelines: @escaping () -> Void = {}
    ) {
        self.availableJobsCount = availableJobsCount
        self.networkRewardsCount = networkRewardsCount
        self.onStartJourney = onStartJourney
        self.onReviewGuidelines = onReviewGuidelines
    }

    func startJourneyTapped() { onStartJourney() }
    func reviewGuidelinesTapped() { onReviewGuidelines() }
}