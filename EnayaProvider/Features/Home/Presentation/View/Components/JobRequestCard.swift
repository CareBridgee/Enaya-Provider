import SwiftUI

struct JobRequestCard: View {
    let jobRequest: JobRequest
    let onEditOffer: () -> Void
    let onMakeOffer: () -> Void

    @State private var isExpanded: Bool = false
    private var isPending: Bool { jobRequest.status == .pending }
    private var isCancelled: Bool { jobRequest.status == .cancelled }

    var body: some View {
        VStack(spacing: Spacing.s16) {
            header
            serviceRow
            
            if isExpanded {
                actionButtons
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
        .shadow(color: .black.opacity(isExpanded ? 0.12 : 0.06), radius: Radius.r12, y: Spacing.s4)
        .scaleEffect(isExpanded ? 1.02 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                isExpanded.toggle()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Circle()
                .fill(Color.surfaceVariant)
                .frame(width: Spacing.s48, height: Spacing.s48)
                .overlay(Image(systemName: "person.fill").foregroundColor(.hint))

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(jobRequest.patientLabel)
                    .carelyText(style: .bodyLarge, weight: .semiBold)
                    .foregroundColor(.primaryFont)

                HStack(spacing: Spacing.s4) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSize.s12, height: IconSize.s12)
                    Text(jobRequest.distanceText)
                        .carelyText(style: .caption, weight: .regular)
                }
                .foregroundColor(.secondaryFont)
            }

            Spacer()

            HStack(spacing: Spacing.s8) {
                VStack(alignment: .trailing, spacing: Spacing.s2) {
                    HStack(spacing: Spacing.s8) {
                        Text("$\(String(format: "%.2f", jobRequest.proposedPrice.doubleValue))")
                            .carelyText(style: .bodyLarge, weight: .bold)
                            .foregroundColor(.brandPrimary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondaryFont)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    
                    if isCancelled {
                        Text("Cancelled")
                            .carelyText(style: .caption, weight: .semiBold)
                            .foregroundColor(.red)
                            .padding(.horizontal, Spacing.s8)
                            .padding(.vertical, Spacing.s2)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    } else if !isPending {
                        Text("Estimated")
                            .carelyText(style: .caption, weight: .regular)
                            .foregroundColor(.secondaryFont)
                    } else {
                        Text("Pending")
                            .carelyText(style: .caption, weight: .semiBold)
                            .foregroundColor(.onWarningContainer)
                            .padding(.horizontal, Spacing.s8)
                            .padding(.vertical, Spacing.s2)
                            .background(Color.warningContainer)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var serviceRow: some View {
        HStack(spacing: Spacing.s12) {
            RoundedRectangle.carely(Radius.r8)
                .fill(Color.brandPrimary.opacity(0.1))
                .frame(width: Spacing.s32, height: Spacing.s32)
                .overlay(Image(systemName: "cross.case.fill").foregroundColor(.brandPrimary))

            Text(jobRequest.serviceName)
                .carelyText(style: .bodyRegular, weight: .semiBold)
                .foregroundColor(.primaryFont)

            Spacer()

            Image(systemName: "doc.text")
                .foregroundColor(.brandPrimary)
        }
        .padding(Spacing.s12)
        .background(Color.surfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle.carely(Radius.r12))
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.s12) {
            SecondaryButton(title: "Edit offer", action: onEditOffer)
            PrimaryButton(title: "Make Offer", action: onMakeOffer)
        }
        .padding(.top, Spacing.s8)
    }
}
