//
//  OnboardingViewModel.swift
//  NaviSync
//
//  Created for modern ride-sharing onboarding flow.
//

import SwiftUI
import Combine

enum OnboardingDestination: Hashable {
    case welcome
    case phoneEntry
    case otpVerification
    case home // Or wherever they go after login
}

@MainActor
@Observable
class OnboardingViewModel {
    // Navigation Path
    var path: [OnboardingDestination] = []
    
    // User Inputs
    var phoneNumber: String = "" {
        didSet {
            // Keep only digits
            let filtered = phoneNumber.filter { $0.isNumber }
            if phoneNumber != filtered {
                phoneNumber = filtered
            }
            // Limit to 10 digits
            if phoneNumber.count > 10 {
                phoneNumber = String(phoneNumber.prefix(10))
            }
        }
    }
    
    var otpCode: String = "" {
        didSet {
            // Keep only digits
            let filtered = otpCode.filter { $0.isNumber }
            if otpCode != filtered {
                otpCode = filtered
            }
            // Limit to 6 digits
            if otpCode.count > 6 {
                otpCode = String(otpCode.prefix(6))
            }
        }
    }
    
    // State
    var isPhoneValid: Bool {
        phoneNumber.count == 10
    }
    
    var isOTPValid: Bool {
        otpCode.count == 6
    }
    
    // Format the phone number (e.g. (123) 456-7890) for display in the OTP view
    var formattedPhoneNumber: String {
        guard phoneNumber.count == 10 else { return phoneNumber }
        let areaCode = phoneNumber.prefix(3)
        let middle = phoneNumber.dropFirst(3).prefix(3)
        let last = phoneNumber.dropFirst(6)
        return "+1 (\(areaCode)) \(middle)-\(last)"
    }
    
    // Navigation Actions
    func navigate(to destination: OnboardingDestination) {
        path.append(destination)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func reset() {
        path.removeAll()
        phoneNumber = ""
        otpCode = ""
    }
    
    func completeOnboarding() {
        // Complete the flow, maybe clear the path, set user as authenticated
        // In this implementation we will navigate to home
        navigate(to: .home)
    }
}
