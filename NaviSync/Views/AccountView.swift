//
//  AccountView.swift
//  NaviSync
//
//  Created for NaviSync.
//  Combines Airbnb's clean minimal typography & row list architecture
//  with Zomato's dark gold-tier membership card, quick-action tiles, and colored section accents.
//  Includes distinct Show Profile (public host profile) and Edit Profile sheets.
//

import SwiftUI

// MARK: - Airbnb-style Clean Menu Row
struct AirbnbMenuRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var badgeText: String? = nil
    var badgeColor: Color = .blue
    var showChevron: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let badgeText = badgeText {
                    Text(badgeText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.45))
                }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Zomato-style Section Header with Colored Indicator Bar
struct ZomatoSectionHeader: View {
    let title: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4, height: 18)
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 6)
    }
}

// MARK: - Main Account View
struct AccountView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @Environment(AppRouter.self) private var router
    
    // User Profile State
    @State private var userName = "Alex Rivera"
    @State private var userEmail = "alex.rivera@example.com"
    @State private var userPhone = "+1 (704) 555-0100"
    @State private var userLocation = "Charlotte, NC"
    @State private var userBio = "Passionate road-tripper & meetup coordinator in Charlotte, NC. Frequently organizes joint drives to the Blue Ridge Parkway."
    @State private var userStatus = "Open to sync"
    @State private var profileCompletion: Int = 85
    
    // Settings & Preferences
    @State private var defaultTravelMode = "Driving"
    @State private var distanceUnits = "Miles (mi)"
    @State private var mapStyle = "Standard"
    @State private var notificationsEnabled = true
    @State private var autoStartLiveActivity = true
    @State private var useFaceID = true
    
    // Modals & Sheets (Separated Show Profile and Edit Profile)
    @State private var isShowingShowProfile = false
    @State private var isShowingEditProfile = false
    @State private var isShowingPrivacyPolicy = false
    @State private var isShowingProUpgradeSheet = false
    @State private var isShowingTravelModePicker = false
    @State private var isShowingUnitsPicker = false
    @State private var isShowingMapStylePicker = false
    @State private var isShowingClearCacheAlert = false
    @State private var isShowingSignOutAlert = false
    
    // Brand Palette
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    private let brandGold = Color(red: 0.95, green: 0.78, blue: 0.38)
    private let travelModes = ["Driving", "Transit", "Walking", "Bicycling"]
    private let unitOptions = ["Miles (mi)", "Kilometers (km)"]
    private let mapStyles = ["Standard", "Satellite", "Hybrid"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // 1. Zomato-inspired Dark Gold-Tier Membership Hero Card
                    membershipHeroCard
                    
                    // 2. Zomato 2-Column Action Tiles (Active Meetings & Live Broadcast)
                    quickTilesRow
                    
                    // 3. Airbnb-style Hero Feature Card ("Host your own joint meeting")
                    airbnbHostPromoCard
                    
                    // 4. Zomato-style Profile Status & Verification Row
                    statusPillRow
                    
                    // 5. Navigation & Preferences Section (Zomato colored bar + Airbnb list rows)
                    navigationPreferencesSection
                    
                    // 6. Security & Privacy Section (Blue accent bar + toggles)
                    securityPrivacySection
                    
                    // 7. Telemetry & Simulation Section (Cyan accent bar)
                    simulationSection
                    
                    // 8. Account Actions & Sign Out
                    accountActionsSection
                    
                    // App Footer
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24) // Tab bar clearance is provided by ContentView's safeAreaInset
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profile")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }
                }
            }
            // Dedicated "Show Profile" public presentation sheet
            .sheet(isPresented: $isShowingShowProfile) {
                ShowProfileSheet(
                    userName: userName,
                    userEmail: userEmail,
                    userPhone: userPhone,
                    userLocation: userLocation,
                    userBio: userBio,
                    userStatus: userStatus,
                    onEditRequested: {
                        isShowingShowProfile = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isShowingEditProfile = true
                        }
                    }
                )
            }
            // Dedicated "Edit Profile" editor sheet
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileSheet(
                    userName: $userName,
                    userPhone: $userPhone,
                    userEmail: $userEmail,
                    userLocation: $userLocation,
                    userBio: $userBio,
                    userStatus: $userStatus
                )
            }
            .sheet(isPresented: $isShowingPrivacyPolicy) {
                PrivacyPolicySheet()
            }
            .sheet(isPresented: $isShowingProUpgradeSheet) {
                ProUpgradeSheet()
            }
            .confirmationDialog("Select Travel Mode", isPresented: $isShowingTravelModePicker, titleVisibility: .visible) {
                ForEach(travelModes, id: \.self) { mode in
                    Button(mode) { defaultTravelMode = mode }
                }
                Button("Cancel", role: .cancel) { }
            }
            .confirmationDialog("Select Distance Units", isPresented: $isShowingUnitsPicker, titleVisibility: .visible) {
                ForEach(unitOptions, id: \.self) { unit in
                    Button(unit) { distanceUnits = unit }
                }
                Button("Cancel", role: .cancel) { }
            }
            .confirmationDialog("Select Map Style", isPresented: $isShowingMapStylePicker, titleVisibility: .visible) {
                ForEach(mapStyles, id: \.self) { style in
                    Button(style) { mapStyle = style }
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Reset Saved Data?", isPresented: $isShowingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "NaviSync_Saved_Meetings_v1")
                }
            } message: {
                Text("This will restore default meeting sample data and clear local cache.")
            }
            .alert("Sign Out?", isPresented: $isShowingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    router.navigate(to: .splash)
                }
            } message: {
                Text("You will need to re-authenticate to sync your live meetings.")
            }
        }
    }
    
    // MARK: - 1. Zomato Dark Gold Membership Card
    private var membershipHeroCard: some View {
        VStack(spacing: 0) {
            // Profile Info Header
            HStack(spacing: 16) {
                // Gold Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.90, blue: 0.72), Color(red: 0.88, green: 0.74, blue: 0.46)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Text(userInitials)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.08))
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(userName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(brandGold)
                            .font(.system(size: 16))
                    }
                    
                    Text(userEmail)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.75))
                    
                    // Triggers the rich public profile sheet
                    Button {
                        isShowingShowProfile = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Show profile")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(brandGold)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(18)
            
            // Bottom Gold Membership Strip (Zomato style)
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(brandGold)
                    
                    Text("Gold Host Member")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.95, green: 0.85, blue: 0.55))
                }
                
                Spacer()
                
                Button {
                    isShowingProUpgradeSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Text("1 new perk")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(brandGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(brandGold.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(brandGold)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.35))
        }
        .background(
            ZStack {
                Color(red: 0.11, green: 0.12, blue: 0.16)
                
                // Geometric watermark lines
                GeometryReader { geo in
                    Path { path in
                        for i in stride(from: 0, to: Int(geo.size.width + geo.size.height), by: 36) {
                            path.move(to: CGPoint(x: CGFloat(i), y: 0))
                            path.addLine(to: CGPoint(x: 0, y: CGFloat(i)))
                        }
                    }
                    .stroke(Color.white.opacity(0.025), lineWidth: 1)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - 2. Zomato 2-Column Action Tiles
    private var quickTilesRow: some View {
        HStack(spacing: 14) {
            // Tile 1: Active Meetings
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 42, height: 42)
                        Image(systemName: "map.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active Meetings")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(meetingStore.meetings.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
            
            // Tile 2: Live Activity Telemetry
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(meetingStore.isSimulatingLiveMovement ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                            .frame(width: 42, height: 42)
                        Image(systemName: meetingStore.isSimulatingLiveMovement ? "antenna.radiowaves.left.and.right" : "bolt.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(meetingStore.isSimulatingLiveMovement ? .green : .orange)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Live Broadcast")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(meetingStore.isSimulatingLiveMovement ? "Broadcasting" : "Standby")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(meetingStore.isSimulatingLiveMovement ? .green : .primary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
    }
    
    // MARK: - 3. Airbnb Hero Promo Card ("Airbnb your place" Style)
    private var airbnbHostPromoCard: some View {
        Button {
            isShowingProUpgradeSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Host joint meetups with Pro")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Share a single invite link to track everyone's live route & ETA in real-time.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Isometric 3D Pin / Navigation badge (Airbnb house style)
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [brandMagenta, Color(red: 0.47, green: 0.16, blue: 0.79)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: brandMagenta.opacity(0.35), radius: 8, y: 4)
                    
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding(18)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 4. Zomato Status & Progress Row
    private var statusPillRow: some View {
        Button {
            isShowingShowProfile = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 20))
                    .foregroundColor(brandMagenta)
                    .frame(width: 28, height: 28)
                
                Text("Navigation profile")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .layoutPriority(1)
                
                Spacer(minLength: 8)
                
                Text("\(profileCompletion)% done")
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(brandMagenta)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(brandMagenta.opacity(0.12))
                    .clipShape(Capsule())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 5. Navigation Preferences Section (Zomato Bar + Airbnb List)
    private var navigationPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZomatoSectionHeader(title: "Navigation & Telemetry", accentColor: brandMagenta)
            
            VStack(spacing: 0) {
                AirbnbMenuRow(
                    icon: "car.fill",
                    iconColor: .orange,
                    title: "Travel Mode",
                    badgeText: defaultTravelMode,
                    badgeColor: .orange,
                    action: { isShowingTravelModePicker = true }
                )
                
                Divider().padding(.leading, 44)
                
                AirbnbMenuRow(
                    icon: "ruler.fill",
                    iconColor: .cyan,
                    title: "Distance Units",
                    badgeText: distanceUnits,
                    badgeColor: .cyan,
                    action: { isShowingUnitsPicker = true }
                )
                
                Divider().padding(.leading, 44)
                
                AirbnbMenuRow(
                    icon: "map.fill",
                    iconColor: .indigo,
                    title: "Map Style",
                    badgeText: mapStyle,
                    badgeColor: .indigo,
                    action: { isShowingMapStylePicker = true }
                )
                
                Divider().padding(.leading, 44)
                
                AirbnbMenuRow(
                    icon: "car.side.fill",
                    iconColor: .purple,
                    title: "Apple CarPlay",
                    subtitle: "Dashboard interactive template",
                    badgeText: "Connected",
                    badgeColor: .green,
                    action: { }
                )
            }
            .padding(.horizontal, 18)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
    }
    
    // MARK: - 6. Security & Privacy Section
    private var securityPrivacySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZomatoSectionHeader(title: "Security & Privacy", accentColor: .blue)
            
            VStack(spacing: 0) {
                AirbnbMenuRow(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Location Sharing",
                    subtitle: "Active joint meetings only",
                    badgeText: "Active Only",
                    badgeColor: .green,
                    showChevron: false,
                    action: { }
                )
                
                Divider().padding(.leading, 44)
                
                HStack(spacing: 16) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                    
                    Text("Push Notifications")
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                        .tint(brandMagenta)
                }
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 44)
                
                HStack(spacing: 16) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .frame(width: 28, height: 28)
                    
                    Text("Auto-Start Live Activity")
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Toggle("", isOn: $autoStartLiveActivity)
                        .labelsHidden()
                        .tint(brandMagenta)
                }
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 44)
                
                HStack(spacing: 16) {
                    Image(systemName: "faceid")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                    
                    Text("Require Face ID")
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Toggle("", isOn: $useFaceID)
                        .labelsHidden()
                        .tint(brandMagenta)
                }
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 44)
                
                AirbnbMenuRow(
                    icon: "hand.raised.fill",
                    iconColor: .indigo,
                    title: "Privacy Policy",
                    subtitle: "Zero third-party tracking guarantee",
                    action: { isShowingPrivacyPolicy = true }
                )
            }
            .padding(.horizontal, 18)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
    }
    
    // MARK: - 7. Simulation Section
    private var simulationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZomatoSectionHeader(title: "Simulation & Tools", accentColor: .cyan)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lock Screen Dynamic Island Sim")
                            .font(.system(size: 15, weight: .semibold))
                        Text(meetingStore.isSimulatingLiveMovement ? "Broadcasting coordinates on lock screen..." : "Test real-time participant journey updates")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button {
                        meetingStore.toggleLiveSimulation(isHost: true)
                    } label: {
                        Text(meetingStore.isSimulatingLiveMovement ? "Stop Host" : "Simulate Host")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(meetingStore.isSimulatingLiveMovement ? Color.red : Color.blue)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        meetingStore.toggleLiveSimulation(isHost: false)
                    } label: {
                        Text(meetingStore.isSimulatingLiveMovement ? "Stop Guest" : "Simulate Guest")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(meetingStore.isSimulatingLiveMovement ? Color.red : Color.green)
                            .clipShape(Capsule())
                    }
                }
                
                Button {
                    router.navigate(to: .splash)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Replay Starting Animation & Auth Flow")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(brandMagenta)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(brandMagenta.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
    }
    
    // MARK: - 8. Account Actions
    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                isShowingClearCacheAlert = true
            } label: {
                Text("Reset Sample Meeting Data")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Button {
                isShowingSignOutAlert = true
            } label: {
                Text("Sign Out")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }
    
    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("NaviSync v1.2 • Build 2026.9.1")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary.opacity(0.8))
            Text("Real-Time Group Navigation & Multi-Map Tracking")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.top, 10)
    }
    
    private var userInitials: String {
        let parts = userName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return "\(userName.prefix(2))".uppercased()
    }
}

// MARK: - Dedicated Show Profile Sheet (Public Host Profile View)
struct ShowProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    let userName: String
    let userEmail: String
    let userPhone: String
    let userLocation: String
    let userBio: String
    let userStatus: String
    let onEditRequested: () -> Void
    
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    private let brandGold = Color(red: 0.95, green: 0.78, blue: 0.38)
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero Profile Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.98, green: 0.90, blue: 0.72), Color(red: 0.88, green: 0.74, blue: 0.46)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                            
                            Text(userInitials)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.08))
                            
                            // Verification Checkmark Seal
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color.blue)
                                        .background(Circle().fill(Color.white).padding(2))
                                }
                            }
                            .frame(width: 90, height: 90)
                        }
                        .padding(.top, 8)
                        
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            
                            Text(userLocation)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            Text("Gold Host Member • Member since 2026")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(brandMagenta)
                                .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    // Host Meetup Stats Grid
                    HStack(spacing: 12) {
                        profileStatCard(title: "Meetups", value: "18", subtitle: "Hosted")
                        profileStatCard(title: "On-Time", value: "99.4%", subtitle: "Arrival rate")
                        profileStatCard(title: "Rating", value: "4.9 ★", subtitle: "Host score")
                    }
                    
                    // Trust & Verification Checklist
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Verified Credentials")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        
                        VStack(spacing: 10) {
                            verifiedRow(icon: "checkmark.shield.fill", title: "Identity Confirmed", color: .green)
                            verifiedRow(icon: "phone.fill", title: userPhone, color: .blue)
                            verifiedRow(icon: "envelope.fill", title: userEmail, color: .indigo)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    
                    // About Bio Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        
                        Text(userBio.isEmpty ? "No bio written yet." : userBio)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    
                    // Travel Tags
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Trip Preferences")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 8) {
                            Text("🚗 Highway Cruising")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.12))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                            
                            Text("⚡️ Live Activities")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.12))
                                .foregroundColor(.purple)
                                .clipShape(Capsule())
                            
                            Text("📱 CarPlay")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.12))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    
                    // Button to open Edit Profile
                    Button {
                        onEditRequested()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .bold))
                            Text("Edit Profile")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(brandMagenta)
                        .clipShape(Capsule())
                        .shadow(color: brandMagenta.opacity(0.3), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Host Profile")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private func profileStatCard(title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private func verifiedRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
        }
    }
    
    private var userInitials: String {
        let parts = userName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return "\(userName.prefix(2))".uppercased()
    }
}

// MARK: - Dedicated Edit Profile Sheet (Interactive Profile Editor)
struct EditProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @Binding var userPhone: String
    @Binding var userEmail: String
    @Binding var userLocation: String
    @Binding var userBio: String
    @Binding var userStatus: String
    
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    private let statusOptions = ["Open to sync", "En route", "At meeting spot", "Busy / Do Not Disturb"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Avatar Photo Picker Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.98, green: 0.90, blue: 0.72), Color(red: 0.88, green: 0.74, blue: 0.46)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 84, height: 84)
                                
                                Text(userInitials)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.08))
                                
                                // Camera Badge
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "camera.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(brandMagenta)
                                            .background(Circle().fill(Color.white).padding(2))
                                    }
                                }
                                .frame(width: 84, height: 84)
                            }
                            
                            Button("Change Profile Photo") {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(brandMagenta)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // Personal Information Section
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Name")
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("Full Name", text: $userName)
                    }
                    
                    HStack {
                        Text("Location")
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("City, State", text: $userLocation)
                    }
                    
                    HStack {
                        Text("Phone")
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("Phone Number", text: $userPhone)
                            #if !os(macOS)
                            .keyboardType(.phonePad)
                            #endif
                    }
                    
                    HStack {
                        Text("Email")
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("Email Address", text: $userEmail)
                            #if !os(macOS)
                            .keyboardType(.emailAddress)
                            #endif
                    }
                }
                
                // About / Bio Section
                Section(header: Text("About You (Public Bio)")) {
                    TextField("Write a short bio for group road trips & meetups...", text: $userBio, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                // Meetup Status Preference
                Section(header: Text("Default Meeting Status")) {
                    Picker("Status", selection: $userStatus) {
                        ForEach(statusOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Edit Profile")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundColor(brandMagenta)
                }
            }
        }
    }
    
    private var userInitials: String {
        let parts = userName.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return "\(userName.prefix(2))".uppercased()
    }
}

// MARK: - Pro Upgrade Modal Sheet
struct ProUpgradeSheet: View {
    @Environment(\.dismiss) var dismiss
    private let brandMagenta = Color(red: 0.85, green: 0.05, blue: 0.53)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [brandMagenta, Color(red: 0.47, green: 0.16, blue: 0.79)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)
                
                VStack(spacing: 8) {
                    Text("NaviSync Gold Host Pro")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                    Text("Enjoy priority multi-map recalculation, unlimited participant tracking, and Apple CarPlay telemetry.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    ProFeatureRow(icon: "bolt.fill", title: "Unlimited Group Size", subtitle: "Track 20+ friends simultaneously on one map.")
                    ProFeatureRow(icon: "antenna.radiowaves.left.and.right", title: "Sub-Second GPS Refresh", subtitle: "Live telemetry without background throttling.")
                    ProFeatureRow(icon: "car.circle.fill", title: "CarPlay High-Def Mode", subtitle: "Real-time ETA overlays on your vehicle screen.")
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Start 7-Day Free Trial ($4.99/mo)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(brandMagenta)
                        .clipShape(Capsule())
                        .shadow(color: brandMagenta.opacity(0.35), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.85, green: 0.05, blue: 0.53))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Privacy Policy Sheet
struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("NaviSync Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Last updated: August 8, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("1. Real-Time Location Privacy")
                        .font(.headline)
                    Text("NaviSync collects your location data only when you are actively participating in an accepted joint meeting. Location streaming stops automatically upon arrival or when you end the trip.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("2. Participant Data Sharing")
                        .font(.headline)
                    Text("Your live coordinates, estimated time of arrival (ETA), and travel speed are shared exclusively with confirmed participants of the specific meeting you joined.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("3. Data Security")
                        .font(.headline)
                    Text("All location transmission occurs over encrypted HTTPS connections using end-to-end authentication protocols.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(MeetingStore())
            .environment(AppRouter())
    }
}
