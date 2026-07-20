import SwiftUI

struct ServiceSelectionGrid: View {
    let selected: Set<CareService>
    let onToggle: (CareService) -> Void

    private let columns = [GridItem(.flexible(), spacing: Spacing.s12), GridItem(.flexible(), spacing: Spacing.s12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.s12) {
            ForEach(CareService.allCases) { service in
                PrimaryChip(
                    image: Image(systemName: service.icon),
                    title: service.title,
                    isSelected: selected.contains(service)
                )
                .onTapGesture { onToggle(service) }
            }
        }
    }
}