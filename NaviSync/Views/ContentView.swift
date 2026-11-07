//
//  ContentView.swift
//  NaviSync
//
//  Created by Mrinal Raj on 7/29/26.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(AppRouter.self) private var appRouter
    @EnvironmentObject var meetingStore: MeetingStore
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        // Active Tab Screen
        Group {
            switch appRouter.selectedTab {
            case 0:
                MultiMapView()
            case 1:
                MeetingListView()
            case 2:
                HistoryView()
            case 3:
                AccountView()
            default:
                MultiMapView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Dedicated Glassmorphism Menu Bar, inset into the safe area so every
        // tab's content (scroll views, floating drawers) automatically clears it.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            customBottomTabBar
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            locationManager.requestAuthorization()
        }
        .sheet(item: $deepLinkManager.activeInvitePayload) { payload in
            InviteResponseView(payload: payload) {
                deepLinkManager.activeInvitePayload = nil
                appRouter.selectedTab = 0 // Switch to Multi-Map to show updated participants
            }
        }
    }
    
    private var customBottomTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(index: 0, title: "Multi-Map", icon: "map.fill")
            tabBarItem(index: 1, title: "Meetings", icon: "person.3.sequence.fill")
            tabBarItem(index: 2, title: "History", icon: "clock.fill")
            tabBarItem(index: 3, title: "Account", icon: "person.crop.circle.fill")
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Rectangle()
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.13).opacity(0.88))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
            }
            .shadow(color: .black.opacity(0.35), radius: 10, y: -3)
            .ignoresSafeArea(edges: .bottom) // extend glass behind the home indicator
        )
    }
    
    private func tabBarItem(index: Int, title: String, icon: String) -> some View {
        let isSelected = (appRouter.selectedTab == index)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                appRouter.selectedTab = index
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.35), Color.cyan.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 28)
                            .overlay(
                                Capsule()
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                    }
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct AppClipGuideView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Instant Applet / App Clip Capability")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "app.clip")
                                .font(.title)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("No App Installation Needed")
                                    .font(.headline)
                                Text("Applet / Universal Link Invitation")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("When Person X sends an invitation URL (`navisync://meeting?id=...` or `https://navisync.app/m/...`), friends without the app installed instantly launch the **NaviSync App Clip** from Apple App Store.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("How NaviSync Works")) {
                    FeatureGuideRow(icon: "1.circle.fill", color: .purple, title: "Create Joint Meeting", subtitle: "Person X drops a pin or picks a spot and creates a meeting with host details.")
                    FeatureGuideRow(icon: "2.circle.fill", color: .blue, title: "Share Invitation URL", subtitle: "Send the link via SMS, WhatsApp, or iMessage to your group.")
                    FeatureGuideRow(icon: "3.circle.fill", color: .green, title: "Friends Accept / Decline", subtitle: "Invited friends open link, see the location, and provide name, contact, and origin.")
                    FeatureGuideRow(icon: "4.circle.fill", color: .indigo, title: "Multi-Map & CarPlay Tracking", subtitle: "Person X sees all accepted participant locations, distances, and ETAs in real-time on iPhone & CarPlay while driving!")
                }
                
                Section(header: Text("Device Privacy & Policies")) {
                    Label("CoreLocation Precision Privacy Supported", systemImage: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Label("CarPlay Template Framework Integrated", systemImage: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Label("Deep Link & Universal Link Parser Configured", systemImage: "checkmark.shield.fill")
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Applet & System Policies")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

struct FeatureGuideRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MeetingStore())
            .environmentObject(DeepLinkManager())
            .environmentObject(LocationManager())
    }
}
