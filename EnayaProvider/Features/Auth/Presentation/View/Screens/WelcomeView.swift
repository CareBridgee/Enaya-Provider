//
//  AuthView.swift
//  Carely
//
//  Created by Mina on 15/07/2026.
//

import Foundation
import SwiftUI

struct WelcomeView : View {
    @StateObject private var viewModel: WelcomeViewModel
    
    init(viewModel: WelcomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Image.careConnect
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
            
            Spacer()
            
            Text("Care Connect")
                .carelyText(style: .display, weight: .light)
                .foregroundColor(.brandPrimary)
                
            Text("Reassuring care for you and your loved ones")
                .carelyText(style: .bodyRegular, weight: .light)
            
            Spacer()
            
            loginButton(
                title: "Continue with Google",
                image: .googleIcon,
                backgroundColor: .surface,
                foregroundColor: .onSurface,
                horizontalPadding: 24,
                strokeColor: Color.secondary
            ) {
                // Fetch the root view controller safely to present the Google Sign-In modal
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController {
                    viewModel.continueWithGoogle(presentingWindow: rootVC)
                }
            }
            .disabled(viewModel.isLoading)
            
            loginButton(
                title: "Continue with Phone",
                image: Image(systemName: "phone"),
                backgroundColor: .mintSurface,
                foregroundColor: .brandPrimary,
                horizontalPadding: 24,
                strokeColor: Color.primaryVariant
            ) {
                viewModel.continueWithPhone()
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 8)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .carelyText(style: .caption)
                    .foregroundColor(.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            termsAndPrivacyText
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backGround)
    }
    
    private var termsAndPrivacyText: some View {
        (
            Text("Joining our app means you agree with our ")
                .foregroundColor(.secondaryFont)
            +
            Text("Terms of use ")
                .foregroundColor(.brandPrimary)
                .bold()
            +
            Text("and ")
                .foregroundColor(.primaryFont)
                .bold()
            +
            Text("privacy policy")
                .foregroundColor(.brandPrimary)
                .bold()
        )
        .carelyText(style: .bodySmall, weight: .regular)
        .multilineTextAlignment(.center)
    }
}
