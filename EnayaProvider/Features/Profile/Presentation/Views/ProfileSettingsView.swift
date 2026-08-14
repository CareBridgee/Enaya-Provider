//
//  ProfileSettingsView.swift
//  EnayaProvider
//
//  Created by AI.
//

import SwiftUI

struct ProfileSettingsView: View {
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppHeader(
                title: "NurseConnect",
                showBackButton: true,
                trailingIcon: nil
            )
            .padding(.horizontal, Spacing.s20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    
                    // Header Texts
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Settings")
                            .carelyText(style: .heading1, weight: .bold)
                            .foregroundColor(.primaryFont)
                        
                        Text("Manage your account and app experience")
                            .carelyText(style: .bodyRegular, weight: .regular)
                            .foregroundColor(.secondaryFont)
                    }
                    .padding(.top, Spacing.s16)
                    
                    // App Preferences Section
                    VStack(alignment: .leading, spacing: Spacing.s12) {
                        Text("App Preferences")
                            .carelyText(style: .bodyRegular, weight: .bold)
                            .foregroundColor(.brandPrimary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 0) {
                            // Language Row
                            Button(action: {
                                // Action for Language
                            }) {
                                HStack(spacing: Spacing.s16) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 20))
                                        .foregroundColor(.secondaryFont)
                                    
                                    Text("Language")
                                        .carelyText(style: .bodyRegular, weight: .regular)
                                        .foregroundColor(.primaryFont)
                                    
                                    Spacer()
                                    
                                    Text("English")
                                        .carelyText(style: .bodyRegular, weight: .regular)
                                        .foregroundColor(.secondaryFont)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondaryFont)
                                }
                                .padding(.vertical, Spacing.s16)
                                .padding(.horizontal, Spacing.s20)
                            }
                            
                            Divider()
                                .padding(.leading, Spacing.s56)
                            
                            // Dark Mode Row
                            HStack(spacing: Spacing.s16) {
                                Image(systemName: "moon")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondaryFont)
                                
                                Text("Dark Mode")
                                    .carelyText(style: .bodyRegular, weight: .regular)
                                    .foregroundColor(.primaryFont)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkModeEnabled)
                                    .labelsHidden()
                            }
                            .padding(.vertical, Spacing.s16)
                            .padding(.horizontal, Spacing.s20)
                        }
                        .background(Color.white)
                        .cornerRadius(Radius.r24)
                        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
                    }
                    
                    // Security & Privacy Section
                    VStack(alignment: .leading, spacing: Spacing.s12) {
                        Text("Security & Privacy")
                            .carelyText(style: .bodyRegular, weight: .bold)
                            .foregroundColor(.brandPrimary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 0) {
                            // Privacy Policy Row
                            Button(action: {
                                // Action for Privacy Policy
                            }) {
                                HStack(spacing: Spacing.s16) {
                                    Image(systemName: "shield")
                                        .font(.system(size: 20))
                                        .foregroundColor(.secondaryFont)
                                    
                                    Text("Privacy Policy")
                                        .carelyText(style: .bodyRegular, weight: .regular)
                                        .foregroundColor(.primaryFont)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondaryFont)
                                }
                                .padding(.vertical, Spacing.s16)
                                .padding(.horizontal, Spacing.s20)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(Radius.r24)
                        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
                    }
                    
                }
                .padding(.horizontal, Spacing.s20)
                .padding(.bottom, Spacing.s40)
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
