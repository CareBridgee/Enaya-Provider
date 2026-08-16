//
//  OnboardingView.swift
//  Carely
//

import SwiftUI

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let illustration: Image
}

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @State private var triggerSwipe: Bool = false
    
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Provide Healthcare",
            description: "Connect with patients in your area and deliver professional home care services.",
            illustration: Image.onboarding1
        ),
        OnboardingPage(
            id: 1,
            title: "Manage Visits",
            description: "Review incoming requests, accept flexible schedules, and manage patient care plans.",
            illustration: Image.onboarding2
        ),
        OnboardingPage(
            id: 2,
            title: "Grow Career",
            description: "Build your professional reputation with patient reviews and track your earnings.",
            illustration: Image.onboarding3
        )
    ]
    
    init(
        viewModel: OnboardingViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            OnboardingTopBar {
                if viewModel.state.currentPageIndex < Self.pages.count {
                    viewModel.onAction(.onSkipClicked)
                }
            }
            .padding(.top, Spacing.s0)
            .padding(.bottom, Spacing.s24)
            
            SwipingCardStack(
                items: Self.pages,
                currentIndex: Binding(
                    get: { viewModel.state.currentPageIndex },
                    set: { viewModel.onAction(.onCardSwiped(newIndex: $0, totalPages: Self.pages.count)) }
                ),
                triggerSwipe: $triggerSwipe,
                maxVisibleCards: 3
            ) { page in
                OnboardingCard(page: page)
            }
            .aspectRatio(0.85, contentMode: .fit)
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: Spacing.s32)
            
            if let currentPage = Self.pages[safe: viewModel.state.currentPageIndex] {
                VStack(spacing: Spacing.s12) {
                    Text(currentPage.title)
                        .carelyText(style: .heading3, weight: .bold)
                        .foregroundColor(.primaryFont)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .scale))
                        .id(currentPage.id)
                    
                    Text(currentPage.description)
                        .carelyText(style: .bodyRegular, weight: .medium)
                        .foregroundColor(.secondaryFont)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.s16)
                        .transition(.opacity.combined(with: .scale))
                        .id("desc_\(currentPage.id)")
                }
                .animation(.easeInOut, value: viewModel.state.currentPageIndex)
            }
            
            Spacer().frame(height: Spacing.s20)
            
            OnboardingPageIndicator(
                pageCount: Self.pages.count,
                currentPage: viewModel.state.currentPageIndex
            )
            
            Spacer()
            
            PrimaryButton(
                title: viewModel.state.currentPageIndex < Self.pages.count - 1 ? "Next" : "Get Started",
                action: {
                    if viewModel.state.currentPageIndex < Self.pages.count - 1 {
                        triggerSwipe = true
                    } else {
                        viewModel.onAction(.onSkipClicked) // Or a specific complete action
                    }
                }
            )
            .padding(.bottom, Spacing.s32)
        }
        .padding(.horizontal, Spacing.s24)
        .background(Color.backGround.ignoresSafeArea())
        .onAppear {
            
        }
    }
}

private struct OnboardingTopBar: View {
    let onSkip: () -> Void
    
    var body: some View {
        HStack {
            Text("\(AppConstants.appName) - Provider")
                .carelyText(style: .heading2, weight: .semiBold)
                .foregroundColor(.brandPrimary)
            
            Spacer()
            
            Button(action: onSkip) {
                Text("Skip")
                    .carelyText(style: .bodyRegular, weight: .medium)
                    .foregroundColor(.secondaryFont)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(onNavigate: {})
    )
}
