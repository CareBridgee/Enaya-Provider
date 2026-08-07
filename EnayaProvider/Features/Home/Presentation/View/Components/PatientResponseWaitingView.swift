//
//  PatientResponseWaitingView.swift
//  EnayaProvider
//
//  Created by Mahmoud Raafat Mustafa on 22/07/2026.
//


import SwiftUI

struct PatientResponseWaitingView: View {
    let onCancel: () -> Void
    
    @State private var timeRemaining: Double = 30.0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: Spacing.s24) {
            
            VStack(spacing: Spacing.s8) {
                ProgressView(value: max(0, timeRemaining), total: 30.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandPrimary))
                    .animation(.linear(duration: 0.1), value: timeRemaining)
                
                Text("\(Int(ceil(max(0, timeRemaining))))s remaining")
                    .carelyText(style: .caption, weight: .bold)
                    .foregroundColor(.brandPrimary)
            }
            .padding(.top, Spacing.s8)
            
            VStack(spacing: Spacing.s8) {
                Text("Waiting for Patient")
                    .carelyText(style: .heading3, weight: .bold)
                    .foregroundColor(.primaryFont)
                
                Text("The patient is reviewing your offer. Please hold on a moment.")
                    .carelyText(style: .bodySmall, weight: .regular)
                    .foregroundColor(.secondaryFont)
                    .multilineTextAlignment(.center)
            }
            
            SecondaryButton(title: "Cancel Offer", action: onCancel)
        }
        .padding(Spacing.s24)
        .background(Color.surface)
        .clipShape(RoundedRectangle.carely(Radius.r24))
        .shadow(color: .black.opacity(0.15), radius: Radius.r24, y: Spacing.s12)
        .padding(.horizontal, Spacing.s32)
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining = max(0, timeRemaining - 0.1)
                if timeRemaining == 0 {
                    onCancel()
                }
            }
        }
    }
}
