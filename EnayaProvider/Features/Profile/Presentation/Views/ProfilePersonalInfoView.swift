//
//  ProfilePersonalInfoView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI
import PhotosUI

struct ProfilePersonalInfoView: View {
    @State var profile: ProfileEntity
    var makeEditBioViewModel: ((@escaping (ProfileEntity) -> Void) -> EditBioViewModel)?
    var onUpdateProfileImage: ((Data) async throws -> ProfileEntity)?
    var fetchVisitsCount: (() async -> Int)?
    var fetchFeaturedReview: (() async -> ReviewEntity?)?
    
    @State private var showEditBio = false
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var isUploadingImage = false
    @State private var uploadErrorMessage: String?
    @State private var completedVisitsCount: Int = 0
    @State private var featuredReview: ReviewEntity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(
                title: "Etmaen",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                VStack(spacing: Spacing.s20) {
                    headerCard
                    
                    HStack(spacing: Spacing.s12) {
                        actionButton(title: "Edit Bio", icon: "pencil") {
                            showEditBio = true
                        }
                    }
                    
                    aboutMeSection
                    reviewsSection
                }
                .padding(.horizontal, Spacing.s20)
                .padding(.top, Spacing.s16)
                .padding(.bottom, Spacing.s40)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditBio) {
            if let factory = makeEditBioViewModel {
                EditBioView(viewModel: factory({ updatedProfile in
                    self.profile = updatedProfile
                    self.showEditBio = false
                }))
            }
        }
        .onChange(of: selectedImageItem) {
            guard let newItem = selectedImageItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        isUploadingImage = true
                        uploadErrorMessage = nil
                    }
                    do {
                        if let onUpdateProfileImage = onUpdateProfileImage {
                            let updated = try await onUpdateProfileImage(data)
                            await MainActor.run {
                                self.profile = updated
                                self.isUploadingImage = false
                                NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: updated.profileImageUrl)
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.isUploadingImage = false
                            self.uploadErrorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
        .task {
            async let visitsTask: () = {
                if let fetchVisitsCount = fetchVisitsCount {
                    let count = await fetchVisitsCount()
                    await MainActor.run {
                        self.completedVisitsCount = count
                    }
                }
            }()
            
            async let reviewTask: () = {
                if let fetchFeaturedReview = fetchFeaturedReview {
                    let review = await fetchFeaturedReview()
                    await MainActor.run {
                        self.featuredReview = review
                    }
                }
            }()
            
            _ = await (visitsTask, reviewTask)
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: Spacing.s16) {
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = profile.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Circle().fill(Color.surfaceVariant)
                                ProgressView()
                                    .tint(.brandPrimary)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            defaultAvatar
                        @unknown default:
                            defaultAvatar
                        }
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.surface, lineWidth: 4))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, y: 5)
                } else {
                    defaultAvatar
                }
                
                if isUploadingImage {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 90, height: 90)
                        ProgressView()
                            .tint(.white)
                    }
                }
                
                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 28, height: 28)
                            .shadow(color: Color.black.opacity(0.15), radius: 3, y: 1)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 2, y: 2)
            }
            
            VStack(spacing: 4) {
                Text(profile.fullName)
                    .font(.title2).bold()
                    .foregroundColor(.primaryFont)
                
                HStack(spacing: 4) {
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(.brandPrimary)
                        .font(.caption)
                    Text(profile.specialization ?? "General")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
            
            HStack(spacing: Spacing.s12) {
                statBox(value: String(format: "%.1f", profile.ratingAvg), label: "\(profile.totalReviews) Reviews")
                statBox(value: "\(profile.yearsOfExperience) yrs", label: "Experience")
                statBox(value: formatVisitsCount(completedVisitsCount), label: "Visits")
            }
        }
        .padding(Spacing.s24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.mintSurface, Color.surface]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(Radius.r24)
    }
    
    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(.brandPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondaryFont)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s12)
        .background(Color.surface)
        .cornerRadius(Radius.r12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
    
    private func formatVisitsCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk+", Double(count) / 1000.0)
        }
        return "\(count)"
    }
    
    private func actionButton(title: String, icon: String, backgroundColor: Color = .brandPrimary, foregroundColor: Color = .onPrimary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline).bold()
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s16)
            .background(backgroundColor)
            .cornerRadius(Radius.r12)
        }
    }
    
    private var aboutMeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.brandPrimary)
                Text("About Me")
                    .font(.headline)
                    .foregroundColor(.primaryFont)
            }
            
            Divider()
            
            Text(profile.bio ?? "Dedicated Registered Nurse...")
                .font(.subheadline)
                .foregroundColor(.secondaryFont)
                .lineSpacing(4)
            
            if !profile.services.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(profile.services, id: \.self) { service in
                        Text(service)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.brandPrimary.opacity(0.15))
                            .foregroundColor(.brandPrimary)
                            .cornerRadius(Radius.r8)
                    }
                }
            }
        }
        .padding(Spacing.s24)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
    }
    
    private var defaultAvatar: some View {
        Circle().fill(Color.surfaceVariant)
            .frame(width: 90, height: 90)
            .overlay(Circle().stroke(Color.surface, lineWidth: 4))
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.hint)
            )
    }
    
    @ViewBuilder
    private var reviewsSection: some View {
        if let review = featuredReview {
            VStack(alignment: .leading, spacing: Spacing.s16) {
                HStack(alignment: .center, spacing: Spacing.s12) {
                    if let urlString = review.reviewerImageUrl, let url = URL(string: urlString) {
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
                                reviewAvatarPlaceholder(name: review.reviewerName)
                            @unknown default:
                                reviewAvatarPlaceholder(name: review.reviewerName)
                            }
                        }
                    } else {
                        reviewAvatarPlaceholder(name: review.reviewerName)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(review.reviewerName)
                            .font(.subheadline).bold()
                            .foregroundColor(.primaryFont)
                        Text(formatReviewDate(review.createdAt))
                            .font(.caption2)
                            .foregroundColor(.secondaryFont)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < review.rating ? "star.fill" : "star")
                                .foregroundColor(.amber)
                                .font(.caption2)
                        }
                    }
                }
                
                if let text = review.reviewText, !text.isEmpty {
                    Text("\"\(text)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondaryFont)
                        .italic()
                        .lineSpacing(3)
                }
            }
            .padding(Spacing.s24)
            .background(Color.surface)
            .cornerRadius(Radius.r24)
        }
    }
    
    private func reviewAvatarPlaceholder(name: String) -> some View {
        Circle()
            .fill(Color.brandPrimary.opacity(0.15))
            .frame(width: 40, height: 40)
            .overlay(
                Text(getInitials(name: name))
                    .font(.caption).bold()
                    .foregroundColor(.brandPrimary)
            )
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
    
    private func formatReviewDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0, +) + CGFloat(rows.count - 1) * spacing
        return CGSize(width: proposal.width ?? .zero, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var currentX: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([view])
                currentX = size.width + spacing
            } else {
                rows[rows.count - 1].append(view)
                currentX += size.width + spacing
            }
        }
        return rows
    }
}
