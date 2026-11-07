//
//  AppRouter.swift
//  NaviSync
//

import SwiftUI

/// Represents the global state of the application routing.
enum AppState {
    case splash
    case onboarding
    case dashboard
}

/// Represents the steps within the onboarding navigation stack.
enum OnboardingStep: Hashable {
    case welcome
    case phoneEntry
    case otpVerification
}

@MainActor
@Observable
class AppRouter {
    var currentState: AppState = .splash
    var onboardingPath: [OnboardingStep] = []
    var selectedTab: Int = 0
    
    init() {
        #if DEBUG
        // Debug-only: `-startTab N` launch argument skips onboarding and opens tab N.
        if UserDefaults.standard.object(forKey: "startTab") != nil {
            currentState = .dashboard
            selectedTab = UserDefaults.standard.integer(forKey: "startTab")
        }
        #endif
    }
    
    /// Navigates to a specific global state
    func navigate(to state: AppState) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentState = state
        }
    }
    
    /// Pushes a new step onto the onboarding navigation stack
    func pushOnboarding(step: OnboardingStep) {
        onboardingPath.append(step)
    }
    
    /// Pops the top view from the onboarding navigation stack
    func popOnboarding() {
        if !onboardingPath.isEmpty {
            onboardingPath.removeLast()
        }
    }
    
    /// Completes onboarding and transitions to the main dashboard
    func completeOnboarding() {
        // Clear onboarding stack
        onboardingPath.removeAll()
        // Transition to main app
        navigate(to: .dashboard)
    }
}
