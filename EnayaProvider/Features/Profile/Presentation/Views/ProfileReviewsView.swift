import SwiftUI

struct ProfileReviewsView: View {
    @StateObject var viewModel: ProfileReviewsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "Reviews",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                if viewModel.isLoading && viewModel.allReviews.isEmpty {
                    ProfileReviewsSkeletonView()
                } else {
                    VStack(spacing: Spacing.s24) {
                        
                        // Rating Summary Card
                        VStack(spacing: Spacing.s16) {
                            VStack(spacing: Spacing.s8) {
                                Text(String(format: "%.1f", viewModel.avgRating))
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.primaryFont)
                                
                                RatingStars(rating: viewModel.avgRating)
                                
                                Text("\(viewModel.totalReviews) Reviews")
                                    .carelyText(style: .bodySmall, weight: .regular)
                                    .foregroundColor(.secondaryFont)
                            }
                            
                            // Rating Distribution dynamically calculated
                            VStack(spacing: Spacing.s8) {
                                RatingRow(star: 5, percentage: viewModel.ratingPercentages[5] ?? 0)
                                RatingRow(star: 4, percentage: viewModel.ratingPercentages[4] ?? 0)
                                RatingRow(star: 3, percentage: viewModel.ratingPercentages[3] ?? 0)
                                RatingRow(star: 2, percentage: viewModel.ratingPercentages[2] ?? 0)
                                RatingRow(star: 1, percentage: viewModel.ratingPercentages[1] ?? 0)
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
                                        withAnimation {
                                            viewModel.selectFilter(filter)
                                        }
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
                            if viewModel.filteredReviews.isEmpty {
                                // Empty State
                                VStack(spacing: Spacing.s16) {
                                    Image(systemName: "star.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondaryFont.opacity(0.5))
                                    Text("No reviews found.")
                                        .carelyText(style: .bodyRegular, weight: .medium)
                                        .foregroundColor(.secondaryFont)
                                }
                                .padding(.vertical, 40)
                            } else {
                                ForEach(viewModel.filteredReviews) { review in
                                    // 👈 Passing the dynamically fetched image URL
                                    ReviewCard(review: review, imageUrl: review.reviewerImageUrl)
                                }
                                
                                // Bottom Loading Indicator
                                if viewModel.isFetchingMore {
                                    ProgressView()
                                        .padding(.vertical, Spacing.s16)
                                }
                                
                                // Load More Button
                                if !viewModel.isLastPage && !viewModel.isLoading && !viewModel.isFetchingMore {
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
                                    .padding(.top, Spacing.s8)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.s20)
                    }
                    .padding(.bottom, 100)
                }
            }
            .refreshable {
                viewModel.fetchReviews(reset: true)
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
            ForEach(0..<5, id: \.self) { i in
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
    var imageUrl: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            
            // 1. Align the entire top row to the top
            HStack(alignment: .top, spacing: Spacing.s12) {
                
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Circle().fill(Color.surfaceVariant)
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.brandPrimary)
                            }
                            .frame(width: 40, height: 40)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure:
                            initialsAvatar
                        @unknown default:
                            initialsAvatar
                        }
                    }
                } else {
                    initialsAvatar
                }
                
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    
                    // 2. Group the Name and Date together
                    HStack(alignment: .top) {
                        Text(review.reviewerName)
                            .carelyText(style: .bodyRegular, weight: .medium)
                            .foregroundColor(.primaryFont)
                            .lineLimit(2) // 👈 Maximum 2 lines
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer(minLength: Spacing.s8)
                        
                        Text(formatDate(review.createdAt))
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryFont)
                            .padding(.top, 2) // Slight adjustment to visually align with text baseline
                    }
                    
                    RatingStars(rating: Double(review.rating))
                }
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
    
    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(width: 40, height: 40)
            Text(getInitials(name: review.reviewerName))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.brandPrimary)
        }
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
// MARK: - Skeleton Views

public struct ProfileReviewsSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: Spacing.s24) {
            RatingSummaryCardSkeleton()
            FilterChipsSkeleton()
            VStack(spacing: Spacing.s16) {
                ForEach(0..<3, id: \.self) { _ in
                    ReviewCardSkeleton()
                }
            }
            .padding(.horizontal, Spacing.s20)
        }
        .padding(.bottom, 100)
    }
}

public struct RatingSummaryCardSkeleton: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: Spacing.s16) {
            VStack(spacing: Spacing.s8) {
                // Score placeholder
                EtmaenSkeletonRect(width: 80, height: 48, radius: Radius.r12)
                
                // Stars placeholder
                EtmaenSkeletonRect(width: 100, height: 14, radius: Radius.r8)
                
                // Total reviews placeholder
                EtmaenSkeletonRect(width: 70, height: 12, radius: Radius.r8)
            }
            
            // 5 Rating row bars
            VStack(spacing: Spacing.s8) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: Spacing.s12) {
                        EtmaenSkeletonRect(width: 12, height: 14, radius: Radius.r4)
                        EtmaenSkeletonRect(height: 8, radius: Radius.r4)
                        EtmaenSkeletonRect(width: 35, height: 12, radius: Radius.r4)
                    }
                }
            }
            .padding(.horizontal, Spacing.s16)
        }
        .padding(.vertical, Spacing.s24)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal, Spacing.s20)
        .padding(.top, Spacing.s16)
    }
}

public struct FilterChipsSkeleton: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: Spacing.s8) {
            EtmaenSkeletonRect(width: 95, height: 34, radius: Radius.r16)
            EtmaenSkeletonRect(width: 85, height: 34, radius: Radius.r16)
            EtmaenSkeletonRect(width: 75, height: 34, radius: Radius.r16)
            Spacer()
        }
        .padding(.horizontal, Spacing.s20)
    }
}

public struct ReviewCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            HStack {
                EtmaenSkeletonCircle(size: 40)

                VStack(alignment: .leading, spacing: Spacing.s4) {
                    EtmaenSkeletonRect(width: 120, height: 14, radius: Radius.r8)
                    EtmaenSkeletonRect(width: 80, height: 10, radius: Radius.r8)
                }

                Spacer()

                EtmaenSkeletonRect(width: 60, height: 14, radius: Radius.r8)
            }

            EtmaenSkeletonText(lines: 2, lineHeight: 12, spacing: Spacing.s4)
        }
        .padding(Spacing.s20)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
        .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
    }
}
