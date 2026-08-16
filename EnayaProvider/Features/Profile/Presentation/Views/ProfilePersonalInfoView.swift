//
//  ProfilePersonalInfoView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct ProfilePersonalInfoView: View {
    @State var profile: ProfileEntity
    var makeEditBioViewModel: ((@escaping (ProfileEntity) -> Void) -> EditBioViewModel)?
    @State private var showEditBio = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(
                title: "NurseConnect",
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
    }
    
    private var headerCard: some View {
        VStack(spacing: Spacing.s16) {
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = profile.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.surfaceVariant
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.surface, lineWidth: 4))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, y: 5)
                } else {
                    Circle().fill(Color.surfaceVariant)
                        .frame(width: 90, height: 90)
                        .overlay(Circle().stroke(Color.surface, lineWidth: 4))
                }
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.brandPrimary)
                    .background(Color.surface)
                    .clipShape(Circle())
                    .offset(x: -5, y: -5)
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
                statBox(value: "1.2k+", label: "Visits")
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
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack {
                Circle()
                    .fill(Color.surfaceVariant)
                    .frame(width: 40, height: 40)
                    .overlay(Text("JD").font(.caption).bold().foregroundColor(.brandPrimary))
                
                VStack(alignment: .leading) {
                    Text("James D.")
                        .font(.subheadline).bold()
                        .foregroundColor(.primaryFont)
                    Text("2 days ago")
                        .font(.caption2)
                        .foregroundColor(.secondaryFont)
                }
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.amber)
                            .font(.caption2)
                    }
                }
            }
            
            Text("\"Sarah was incredible with my father. Her professionalism and warmth made all the difference in his recovery.\"")
                .font(.subheadline)
                .foregroundColor(.secondaryFont)
                .italic()
        }
        .padding(Spacing.s24)
        .background(Color.surface)
        .cornerRadius(Radius.r24)
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
