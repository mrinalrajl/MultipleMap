//
//  OnboardingComponents.swift
//  NaviSync
//
//  Created for modern ride-sharing onboarding flow.
//

import SwiftUI

struct BrandColors {
    static let primary = Color(red: 0.85, green: 0.05, blue: 0.53) // Lyft-style magenta
    static let disabled = Color(red: 0.8, green: 0.65, blue: 0.75) // Faded magenta
    static let textDark = Color.primary
    static let textLight = Color.white
    static let backgroundLight = Color(UIColor.systemBackground)
}

struct PrimaryButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isActive {
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isActive ? BrandColors.textLight : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isActive ? BrandColors.primary : BrandColors.disabled)
                .cornerRadius(30)
        }
        .disabled(!isActive)
    }
}

struct AppleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "applelogo")
                    .font(.system(size: 20))
                Text("Continue with Apple")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct CustomPhoneTextField: View {
    @Binding var text: String
    var onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Country Code selector
            HStack(spacing: 4) {
                Text("🇺🇸") // Emoji flag
                    .font(.system(size: 18))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.trailing, 8)
            .overlay(
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 4)
                , alignment: .trailing
            )
            
            // Prefix
            Text("+1")
                .font(.system(size: 18, weight: .medium))
            
            // TextField
            TextField("Phone number", text: $text)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .medium))
            
            // Clear Button
            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(6)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(BrandColors.primary, lineWidth: 1.5)
        )
    }
}

struct OTPTextField: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("6-digit code", text: $text)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .medium))
                .tracking(8) // Space out digits slightly
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(6)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(BrandColors.primary, lineWidth: 1.5)
        )
    }
}
