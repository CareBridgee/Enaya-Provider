//
//  ServiceSelectionGrid.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 20/07/2026.
//
import SwiftUI

struct ServiceSelectionGrid: View {
    let availableServices: [CareService]
    let selected: Set<CareService>
    let onToggle: (CareService) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.s12),
        GridItem(.flexible(), spacing: Spacing.s12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.s12) {
            ForEach(availableServices) { service in
                AsyncServiceChip(
                    imageUrl: service.iconUrl,
                    fallbackIconName: service.icon,
                    title: service.title,
                    isSelected: selected.contains(service)
                )
                .onTapGesture { onToggle(service) }
            }
        }
    }
}

// MARK: - Patient App Style Tile (Adapted for Selection)
struct AsyncServiceChip: View {
    let imageUrl: String?
    let fallbackIconName: String
    let title: String
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            
            // Image Box
            Group {
                if let urlStr = imageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(Color.brandPrimary)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            fallbackIcon
                        @unknown default:
                            fallbackIcon
                        }
                    }
                } else {
                    fallbackIcon
                }
            }
            .frame(width: 48, height: 48)
            .background(Color.primaryContainer)
            .clipShape(RoundedRectangle.carely(Radius.r16))

            // Service Title
            Text(title)
                .carelyText(style: .bodySmall)
                .foregroundColor(.primaryFont)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                // Forces the text to wrap to the second line instead of truncating
                .fixedSize(horizontal: false, vertical: true)
                // Ensures all cards have a uniform minimum height accommodating 2 lines
                .frame(minHeight: 40, alignment: .topLeading)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.brandPrimary.opacity(0.05) : Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r24))
        // Selection Indicator Border
        .overlay(
            RoundedRectangle.carely(Radius.r24)
                .stroke(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
        )
        .carelyShadow(.sm)
        // Add a subtle scale effect when tapped
        .contentShape(Rectangle())
    }
    
    private var fallbackIcon: some View {
        Image(systemName: fallbackIconName)
            .font(.system(size: 22))
            .foregroundColor(.brandPrimary)
    }
}
