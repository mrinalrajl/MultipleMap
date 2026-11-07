//
//  OnboardingFlowView.swift
//  NaviSync
//
//  Cinematic starting animation loading the native app logo,
//  dynamic telemetry loading state, empty state discovery carousel,
//  and multi-provider authentication (Apple, Google, Phone).
//

import SwiftUI
import AuthenticationServices

// MARK: - Onboarding Phase State
enum OnboardingPhase {
    case splashLoading
    case welcomeAuth
}

// MARK: - Core Container View
struct OnboardingFlowView: View {
    @Environment(AppRouter.self) private var router
    @State private var phase: OnboardingPhase = .splashLoading
    @Namespace private var logoNamespace
    
    var body: some View {
        @Bindable var bindableRouter = router
        NavigationStack(path: $bindableRouter.onboardingPath) {
            ZStack {
                // Shared Midnight Canvas Background
                LinearGradient(
                    colors: [Color(red: 0.10, green: 0.12, blue: 0.20), Color(red: 0.04, green: 0.05, blue: 0.09)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if phase == .splashLoading {
                    SplashLoadingView(
                        namespace: logoNamespace,
                        onComplete: {
                            withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                                phase = .welcomeAuth
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    WelcomeAuthView(namespace: logoNamespace)
                        .transition(.opacity)
                }
            }
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .welcome:
                    EmptyView()
                case .phoneEntry:
                    PhoneEntryView()
                case .otpVerification:
                    OTPVerificationView()
                }
            }
        }
    }
}

// MARK: - 1. Splash & Starting Animation View
struct SplashLoadingView: View {
    let namespace: Namespace.ID
    let onComplete: () -> Void
    
    // Animation States
    @State private var radarPulse = false
    @State private var logoAppeared = false
    @State private var textAppeared = false
    @State private var glintOffset: CGFloat = -180
    @State private var loadingProgress: CGFloat = 0.0
    @State private var statusIndex = 0
    
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    private let brandPurple = Color(red: 0.47, green: 0.16, blue: 0.79)
    
    private let loadingMessages = [
        "Calibrating GPS Telemetry...",
        "Scanning for active meeting mesh...",
        "Syncing CarPlay & Live Activities...",
        "Ready to navigate."
    ]
    
    var body: some View {
        VStack(spacing: 36) {
            Spacer()
            
            // Central Elevated App Logo with Animated Radar Waves
            ZStack {
                // Expanding Radar Ring 1
                Circle()
                    .stroke(brandMagenta.opacity(radarPulse ? 0.0 : 0.45), lineWidth: 2)
                    .frame(width: radarPulse ? 260 : 120, height: radarPulse ? 260 : 120)
                    .animation(.easeOut(duration: 1.9).repeatForever(autoreverses: false), value: radarPulse)
                
                // Expanding Radar Ring 2
                Circle()
                    .stroke(brandPurple.opacity(radarPulse ? 0.0 : 0.35), lineWidth: 2)
                    .frame(width: radarPulse ? 210 : 100, height: radarPulse ? 210 : 100)
                    .animation(.easeOut(duration: 1.9).delay(0.45).repeatForever(autoreverses: false), value: radarPulse)
                
                // Ambient Radial Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [brandMagenta.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                
                // Loaded App Logo with Glass Border & Specular Glint
                ZStack {
                    Image("NaviSyncLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 124, height: 124)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.7), brandMagenta.opacity(0.4), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: brandMagenta.opacity(0.45), radius: 24, x: 0, y: 10)
                        .matchedGeometryEffect(id: "BrandLogo", in: namespace)
                    
                    // Specular Glint Shimmer Sheen
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 140)
                        .rotationEffect(.degrees(25))
                        .offset(x: glintOffset)
                        .mask(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .frame(width: 124, height: 124)
                        )
                }
                .scaleEffect(logoAppeared ? 1.0 : 0.7)
                .opacity(logoAppeared ? 1.0 : 0.0)
            }
            .frame(width: 260, height: 260)
            
            // Brand Typography
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("Navi")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Sync")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(brandMagenta)
                }
                .matchedGeometryEffect(id: "BrandTitle", in: namespace)
                
                Text("REAL-TIME GROUP NAVIGATION")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.65))
            }
            .opacity(textAppeared ? 1 : 0)
            .offset(y: textAppeared ? 0 : 15)
            
            Spacer()
            
            // Loading State Progress Section
            VStack(spacing: 12) {
                // Gradient Progress Bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 5)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, brandMagenta, brandPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 220 * loadingProgress, height: 5)
                        .animation(.linear(duration: 2.2), value: loadingProgress)
                }
                .frame(width: 220)
                
                // Cycling Telemetry Status
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: brandMagenta))
                        .scaleEffect(0.7)
                    
                    Text(loadingMessages[statusIndex])
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .animation(.easeInOut(duration: 0.3), value: statusIndex)
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 32)
        .onAppear {
            runAnimationSequence()
        }
    }
    
    private func runAnimationSequence() {
        // Logo Entrance Spring
        withAnimation(.spring(response: 0.65, dampingFraction: 0.65)) {
            logoAppeared = true
        }
        
        // Trigger continuous radar pulse
        radarPulse = true
        
        // Trigger Glint Sheen across logo
        withAnimation(.easeInOut(duration: 1.1).delay(0.4)) {
            glintOffset = 180
        }
        
        // Reveal text
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            textAppeared = true
        }
        
        // Advance Progress Bar
        loadingProgress = 1.0
        
        // Cycle status messages
        Timer.scheduledTimer(withTimeInterval: 0.60, repeats: true) { timer in
            if statusIndex < loadingMessages.count - 1 {
                withAnimation {
                    statusIndex += 1
                }
            } else {
                timer.invalidate()
            }
        }
        
        // Transition to Welcome & Auth phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onComplete()
        }
    }
}

// MARK: - 2. Welcome, Empty State Carousel & Auth View
struct WelcomeAuthView: View {
    let namespace: Namespace.ID
    @Environment(AppRouter.self) private var router
    
    // Default to Sign In first as requested by user
    @State private var isSignUp = false
    @State private var activeCarouselPage = 0
    
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    private let brandPurple = Color(red: 0.47, green: 0.16, blue: 0.79)
    
    private let featureSlides: [(icon: String, color: Color, title: String, description: String)] = [
        ("map.fill", .cyan, "Real-Time Group Navigation", "See all your friends moving together toward a single meeting location on one live synchronized map."),
        ("bolt.badge.clock.fill", Color(red: 0.85, green: 0.05, blue: 0.53), "Dynamic Island & Live Activities", "Glance at everyone's live distance, speed, and real-time ETA straight from your iPhone Lock Screen."),
        ("car.circle.fill", .purple, "Apple CarPlay Integrated", "Track joint meeting progress on your vehicle dashboard for seamless, hands-free group roadtrips.")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header: Logo Hand-off
                HStack {
                    HStack(spacing: 10) {
                        Image("NaviSyncLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .matchedGeometryEffect(id: "BrandLogo", in: namespace)
                        
                        HStack(spacing: 0) {
                            Text("Navi")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Sync")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(brandMagenta)
                        }
                        .matchedGeometryEffect(id: "BrandTitle", in: namespace)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                
                // Feature Discovery Carousel (Empty State Slides)
                emptyStateCarousel
                
                // Primary Authentication Panel
                VStack(spacing: 14) {
                    // Header text: Sign In comes first
                    VStack(spacing: 4) {
                        Text(isSignUp ? "Create an account" : "Sign in to NaviSync")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(isSignUp ? "Sign up to track friends and coordinate joint trips." : "Welcome back! Enter your details to continue.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.70))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 6)
                    
                    // 1. Sign in with Apple (Native Button)
                    SignInWithAppleButton(isSignUp ? .signUp : .signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                print("Apple Auth success: \(credential.user)")
                            }
                            router.completeOnboarding()
                        case .failure(let error):
                            print("Apple Auth failed: \(error.localizedDescription)")
                            #if targetEnvironment(simulator)
                            router.completeOnboarding()
                            #endif
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 52)
                    .clipShape(Capsule())
                    
                    // 2. Sign in with Google (Authentic Google Identity Style)
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        router.completeOnboarding()
                    } label: {
                        HStack(spacing: 12) {
                            GoogleLogoView()
                            Text(isSignUp ? "Sign up with Google" : "Sign in with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.14))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.87), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    
                    // 3. Continue with Phone Number
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        router.pushOnboarding(step: .phoneEntry)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text(isSignUp ? "Sign up with Phone Number" : "Sign in with Phone Number")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // 4. "Not a current user? Sign up" / "Already have an account? Sign in"
                    HStack(spacing: 4) {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.70))
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                isSignUp.toggle()
                            }
                        } label: {
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(brandMagenta)
                        }
                    }
                    .padding(.top, 6)
                    
                    // 5. Frictionless Demo / Guest Mode Link
                    Button {
                        router.completeOnboarding()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Explore Demo without signing in")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white.opacity(0.50))
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 28)
            }
        }
    }
    
    // MARK: - Feature Carousel
    private var emptyStateCarousel: some View {
        VStack(spacing: 14) {
            TabView(selection: $activeCarouselPage) {
                ForEach(0..<featureSlides.count, id: \.self) { index in
                    let slide = featureSlides[index]
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(slide.color.opacity(0.18))
                                .frame(width: 76, height: 76)
                            
                            Image(systemName: slide.icon)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(slide.color)
                        }
                        .padding(.top, 6)
                        
                        VStack(spacing: 6) {
                            Text(slide.title)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(slide.description)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.72))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .frame(height: 220)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Carousel Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<featureSlides.count, id: \.self) { index in
                    Capsule()
                        .fill(activeCarouselPage == index ? brandMagenta : Color.white.opacity(0.25))
                        .frame(width: activeCarouselPage == index ? 22 : 7, height: 7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeCarouselPage)
                }
            }
        }
    }
}

// MARK: - Google 'G' Logo View (Official 4-Color Geometry)
struct GoogleLogoView: View {
    var body: some View {
        ZStack {
            // Google Red Arc (Top)
            Circle()
                .trim(from: 0.0, to: 0.25)
                .stroke(Color(red: 0.92, green: 0.26, blue: 0.21), lineWidth: 3.5)
                .rotationEffect(.degrees(-45))
            
            // Google Yellow Arc (Left)
            Circle()
                .trim(from: 0.25, to: 0.50)
                .stroke(Color(red: 0.98, green: 0.73, blue: 0.02), lineWidth: 3.5)
                .rotationEffect(.degrees(-45))
            
            // Google Green Arc (Bottom)
            Circle()
                .trim(from: 0.50, to: 0.75)
                .stroke(Color(red: 0.20, green: 0.66, blue: 0.33), lineWidth: 3.5)
                .rotationEffect(.degrees(-45))
            
            // Google Blue Arc (Right)
            Circle()
                .trim(from: 0.75, to: 1.0)
                .stroke(Color(red: 0.26, green: 0.52, blue: 0.96), lineWidth: 3.5)
                .rotationEffect(.degrees(-45))
            
            // Horizontal Crossbar (Blue)
            Rectangle()
                .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
                .frame(width: 9, height: 3.5)
                .offset(x: 3.5)
        }
        .frame(width: 20, height: 20)
    }
}

// MARK: - 3. Phone Entry View
struct PhoneEntryView: View {
    @Environment(AppRouter.self) private var router
    @State private var phoneNumber = ""
    @FocusState private var isFocused: Bool
    
    private var isPhoneValid: Bool {
        phoneNumber.count == 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter Mobile Number")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            Text("We'll text you a 6-digit verification code to sign in or create your profile.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.bottom, 28)
            
            // Phone Input Box
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("🇺🇸")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 8)
                .overlay(
                    Rectangle().fill(Color.secondary.opacity(0.3)).frame(width: 1),
                    alignment: .trailing
                )
                
                Text("+1")
                    .font(.system(size: 18, weight: .semibold))
                
                TextField("Phone number", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .medium))
                    .focused($isFocused)
                    .onChange(of: phoneNumber) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        phoneNumber = String(filtered.prefix(10))
                    }
                
                if !phoneNumber.isEmpty {
                    Button { phoneNumber = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? Color(red: 0.85, green: 0.05, blue: 0.53) : Color.secondary.opacity(0.3), lineWidth: 1.5)
            )
            .padding(.bottom, 24)
            
            Button {
                if isPhoneValid {
                    router.pushOnboarding(step: .otpVerification)
                }
            } label: {
                Text("Send Code")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isPhoneValid ? Color(red: 0.85, green: 0.05, blue: 0.53) : Color.secondary.opacity(0.3))
                    .clipShape(Capsule())
            }
            .disabled(!isPhoneValid)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // FIX: Hides default back button so there's no "< Back <" duplicate
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.popOnboarding() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

// MARK: - 4. OTP Verification View
struct OTPVerificationView: View {
    @Environment(AppRouter.self) private var router
    @State private var otpCode = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter 6-Digit Code")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            Text("Code sent to your phone. Enter it below to complete sign in.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.bottom, 28)
            
            HStack(spacing: 12) {
                TextField("000000", text: $otpCode)
                    .keyboardType(.numberPad)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .tracking(10)
                    .focused($isFocused)
                    .onChange(of: otpCode) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        otpCode = String(filtered.prefix(6))
                        if otpCode.count == 6 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                router.completeOnboarding()
                            }
                        }
                    }
                
                if !otpCode.isEmpty {
                    Button { otpCode = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.85, green: 0.05, blue: 0.53), lineWidth: 1.5)
            )
            .padding(.bottom, 24)
            
            Button {
                if otpCode.count == 6 {
                    router.completeOnboarding()
                }
            } label: {
                Text("Verify & Continue")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(otpCode.count == 6 ? Color(red: 0.85, green: 0.05, blue: 0.53) : Color.secondary.opacity(0.3))
                    .clipShape(Capsule())
            }
            .disabled(otpCode.count != 6)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // FIX: Hides default back button so there's no duplicate
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.popOnboarding() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

// MARK: - Previews
#Preview {
    OnboardingFlowView()
        .environment(AppRouter())
}
