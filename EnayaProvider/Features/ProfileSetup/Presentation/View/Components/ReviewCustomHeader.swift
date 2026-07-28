import SwiftUI

struct ReviewCustomHeader: View {
    var body: some View {
        HStack {
            Button(action: { }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: IconSize.s20, weight: .medium))
                    .foregroundColor(.brandPrimary)
            }
            .frame(width: Spacing.s32, alignment: .leading)
            
            Spacer()
            
            Text("CareConnect")
                .carelyText(style: .heading3, weight: .bold)
                .foregroundColor(.brandPrimary)
            
            Spacer()
            
            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.hint)
                )
        }
    }
}