//
//  PatientSummaryView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 12/08/2026.
//


import SwiftUI

struct PatientSummaryView: View {
    @StateObject var viewModel: PatientSummaryViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.s12),
        GridItem(.flexible(), spacing: Spacing.s12)
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.s16) {
                headerCard
                personalInformationCard
                medicalConditionsCard
                allergiesCard
                medicationsCard
                mobilityNotesCard
                medicalHistoryCard
                emergencyContactsCard
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s32)
        }
        .background(Color.backGround.ignoresSafeArea())
        .EtmaenNavigationBar(title: "Enaya")
        .alert("Request Cancelled", isPresented: $viewModel.showPatientCancelledAlert) {
            Button("OK", role: .cancel) {
                viewModel.handlePatientCancellationAcknowledged()
            }
        } message: {
            Text("We're sorry, the patient has cancelled this request. We are investigating the reason to ensure your compensation. You will now be redirected to the home screen.")
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: Spacing.s12) {
            CarelyAsyncImage(
                url: viewModel.profile.patient.profileImageUrl,
                size: CGSize(width: 80, height: 80)
            )
            .clipShape(Circle())
            
            Text(viewModel.patientName)
                .carelyText(style: .heading2, weight: .bold)
                .foregroundColor(.primaryFont)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.s24)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "PERSONAL INFORMATION")
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.s16) {
                InfoGridItem(icon: "calendar", title: "Age", value: viewModel.age)
                InfoGridItem(icon: "person.text.rectangle", title: "Gender", value: viewModel.gender)
                InfoGridItem(icon: "drop.fill", title: "Blood Type", value: viewModel.bloodType)
                InfoGridItem(icon: "arrow.up.and.down", title: "Height", value: viewModel.height)
                InfoGridItem(icon: "scalemass", title: "Weight", value: viewModel.weight)
                InfoGridItem(icon: "figure.walk", title: "Mobility", value: viewModel.mobility)
            }
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var medicalConditionsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "MEDICAL CONDITIONS")
            
            if viewModel.hasConditions {
                WrappingHStack(items: viewModel.profile.patient.medicalConditions ?? []) { condition in
                    ChipView(text: condition)
                }
            } else {
                Text("No medical conditions recorded")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var allergiesCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            HStack(spacing: Spacing.s8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.error)
                Text("ALLERGIES")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.error)
            }
            
            if viewModel.hasAllergies {
                WrappingHStack(items: viewModel.profile.patient.allergies ?? []) { allergy in
                    ChipView(text: allergy, isError: true)
                }
            } else {
                Text("No known allergies")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var medicationsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "CURRENT MEDICATIONS")
            
            if viewModel.hasMedications {
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    ForEach(viewModel.profile.patient.medications ?? [], id: \.self) { medication in
                        HStack(spacing: Spacing.s12) {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.brandPrimary)
                                .frame(width: 24)
                            Text(medication)
                                .carelyText(style: .bodyRegular, weight: .medium)
                                .foregroundColor(.primaryFont)
                        }
                    }
                }
            } else {
                Text("No current medications listed")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var mobilityNotesCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "MOBILITY & CARE NOTES")
            
            VStack(alignment: .leading, spacing: Spacing.s8) {
                HStack(spacing: 4) {
                    Text("Mobility Status:")
                        .carelyText(style: .bodyRegular, weight: .bold)
                        .foregroundColor(.primaryFont)
                    Text(viewModel.mobility)
                        .carelyText(style: .bodyRegular, weight: .regular)
                        .foregroundColor(.primaryFont)
                }
                
                if let notes = viewModel.profile.patient.mobilityNotes, !notes.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Text("Notes:")
                            .carelyText(style: .bodyRegular, weight: .bold)
                            .foregroundColor(.primaryFont)
                        Text(notes)
                            .carelyText(style: .bodyRegular, weight: .regular)
                            .foregroundColor(.primaryFont)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(Spacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceVariant.opacity(0.3))
            .clipShape(RoundedRectangle.carely(Radius.r12))
        }
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var medicalHistoryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "MEDICAL HISTORY")
            
            if viewModel.hasHistory {
                VStack(alignment: .leading, spacing: Spacing.s0) {
                    let history = viewModel.profile.patient.medicalHistory ?? []
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, item in
                        HistoryTimelineRow(
                            item: item,
                            isLast: index == history.count - 1
                        )
                    }
                }
            } else {
                Text("No medical history recorded")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
    
    private var emergencyContactsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            OfferSectionLabel(title: "EMERGENCY CONTACTS")
            
            if viewModel.hasEmergencyContacts {
                VStack(spacing: Spacing.s12) {
                    ForEach(viewModel.profile.patient.emergencyContacts ?? []) { contact in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(contact.name ?? "") (\(contact.relationship ?? ""))")
                                    .carelyText(style: .bodyRegular, weight: .bold)
                                    .foregroundColor(.primaryFont)
                                Text(contact.phoneNumber ?? "")
                                    .carelyText(style: .bodySmall, weight: .regular)
                                    .foregroundColor(.secondaryFont)
                            }
                            Spacer()
                            if let phone = contact.phoneNumber {
                                Button(action: { viewModel.callEmergencyContact(phone: phone) }) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.white)
                                        .padding(Spacing.s12)
                                        .background(Color.brandPrimary)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(Spacing.s16)
                        .background(Color.surfaceVariant.opacity(0.3))
                        .clipShape(RoundedRectangle.carely(Radius.r12))
                    }
                }
            } else {
                Text("No emergency contacts listed")
                    .carelyText(style: .bodyRegular, weight: .regular)
                    .foregroundColor(.secondaryFont)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.s16)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r16))
    }
}

private struct InfoGridItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Spacing.s12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.brandPrimary)
                .frame(width: 24, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .carelyText(style: .caption, weight: .regular)
                    .foregroundColor(.secondaryFont)
                Text(value)
                    .carelyText(style: .bodyRegular, weight: .semiBold)
                    .foregroundColor(.primaryFont)
            }
        }
    }
}

private struct ChipView: View {
    let text: String
    var isError: Bool = false
    
    var body: some View {
        Text(text)
            .carelyText(style: .bodySmall, weight: .medium)
            .foregroundColor(isError ? .error : .primaryFont)
            .padding(.horizontal, Spacing.s12)
            .padding(.vertical, Spacing.s8)
            .background(isError ? Color.errorContainer : Color.surfaceVariant)
            .clipShape(Capsule())
    }
}

private struct HistoryTimelineRow: View {
    let item: MedicalHistoryDTO
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s16) {
            VStack(spacing: Spacing.s0) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceVariant)
                        .frame(width: 32, height: 32)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.brandPrimary)
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.divider)
                        .frame(width: 2)
                        .padding(.vertical, Spacing.s4)
                }
            }
            
            VStack(alignment: .leading, spacing: Spacing.s4) {
                if let type = item.type {
                    Text(type)
                        .carelyText(style: .caption, weight: .bold)
                        .foregroundColor(.brandPrimary)
                }
                if let desc = item.description {
                    Text(desc)
                        .carelyText(style: .bodyRegular, weight: .medium)
                        .foregroundColor(.primaryFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Spacing.s12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceVariant.opacity(0.3))
            .clipShape(RoundedRectangle.carely(Radius.r12))
            .padding(.bottom, isLast ? 0 : Spacing.s16)
        }
    }
}

private struct WrappingHStack: View {
    var items: [String]
    var viewForItem: (String) -> ChipView
    
    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry.size.width)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in availableWidth: CGFloat) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                viewForItem(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > availableWidth) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
