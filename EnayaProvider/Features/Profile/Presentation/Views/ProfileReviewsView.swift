//
//  ProfileReviewsView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct ProfileReviewsView: View {
    @StateObject var viewModel: ProfileReviewsViewModel
    let avgRating: Double
    let totalReviews: Int
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "Reviews",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                VStack(spacing: Spacing.s24) {
                    
                    // Rating Summary Card
                    VStack(spacing: Spacing.s16) {
                        VStack(spacing: Spacing.s8) {
                            Text(String(format: "%.1f", avgRating))
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.primaryFont)
                            
                            RatingStars(rating: avgRating)
                            
                            Text("\(totalReviews) Reviews")
                                .carelyText(style: .bodySmall, weight: .regular)
                                .foregroundColor(.secondaryFont)
                        }
                        
                        // Rating Distribution
                        VStack(spacing: Spacing.s8) {
                            RatingRow(star: 5, percentage: 92)
                            RatingRow(star: 4, percentage: 6)
                            RatingRow(star: 3, percentage: 1)
                            RatingRow(star: 2, percentage: 1)
                            RatingRow(star: 1, percentage: 0)
                        }
                        .padding(.horizontal, Spacing.s16)
                    }
                    .padding(.vertical, Spacing.s24)
                    .background(Color.surface)
                    .cornerRadius(Radius.r24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal, Spacing.s20)
                    .padding(.top, Spacing.s16)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.s8) {
                            ForEach(viewModel.availableFilters, id: \.self) { filter in
                                Button(action: {
                                    viewModel.selectFilter(filter)
                                }) {
                                    Text(filter)
                                        .carelyText(style: .bodySmall, weight: .medium)
                                        .padding(.horizontal, Spacing.s16)
                                        .padding(.vertical, Spacing.s8)
                                        .background(viewModel.selectedFilter == filter ? Color.brandPrimary : Color.surface)
                                        .foregroundColor(viewModel.selectedFilter == filter ? .onPrimary : .primaryFont)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.divider, lineWidth: viewModel.selectedFilter == filter ? 0 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.s20)
                    }
                    
                    // Reviews List
                    LazyVStack(spacing: Spacing.s16) {
                        ForEach(viewModel.reviews) { review in
                            ReviewCard(review: review)
                        }
                        
                        if viewModel.isLoading || viewModel.isFetchingMore {
                            ProgressView()
                                .padding()
                        } else if viewModel.reviews.isEmpty {
                            Text("No reviews yet.")
                                .foregroundColor(.secondaryFont)
                                .padding()
                        }
                        
                        // Load More Button (if not last page)
                        if !viewModel.reviews.isEmpty && !viewModel.isLoading {
                            Button(action: {
                                viewModel.fetchReviews()
                            }) {
                                Text("Load More Reviews")
                                    .carelyText(style: .bodyRegular, weight: .medium)
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.s12)
                                    .background(Color.surface)
                                    .cornerRadius(Radius.r16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Radius.r16)
                                            .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, Spacing.s20)
                            .padding(.top, Spacing.s8)
                        }
                    }
                    .padding(.horizontal, Spacing.s20)
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchReviews(reset: true)
        }
    }
}

// MARK: - Subviews

struct RatingStars: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Image(systemName: getStarName(index: i))
                    .foregroundColor(.amber)
                    .font(.system(size: 14))
            }
        }
    }
    
    private func getStarName(index: Int) -> String {
        if rating >= Double(index) + 1.0 {
            return "star.fill"
        } else if rating >= Double(index) + 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

struct RatingRow: View {
    let star: Int
    let percentage: Int
    
    var body: some View {
        HStack(spacing: Spacing.s12) {
            Text("\(star)")
                .font(.system(size: 14))
                .foregroundColor(.secondaryFont)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.surfaceVariant)
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.brandPrimary)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100.0, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(percentage)%")
                .font(.system(size: 12))
                .foregroundColor(.secondaryFont)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

struct ReviewCard: View {
    let review: ReviewEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                // Avatar Initials
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(getInitials(name: review.reviewerName))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brandPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .carelyText(style: .bodyRegular, weight: .medium)
                        .foregroundColor(.primaryFont)
                    
                    RatingStars(rating: Double(review.rating))
                }
                
                Spacer()
                
                Text(formatDate(review.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryFont)
            }
            
            if let text = review.reviewText, !text.isEmpty {
                Text(text)
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.primaryFont)
                    .lineLimit(nil)
            }
            
            // Service Pill
            HStack(spacing: Spacing.s8) {
                Image(systemName: "cross.case")
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 12))
                Text(review.serviceName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.brandPrimary)
            }
        }
        .padding(Spacing.s20)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
        .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
    }
    
    private func getInitials(name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            return "\(first)".uppercased()
        }
        return "?"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}
