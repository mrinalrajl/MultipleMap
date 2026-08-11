//
//  ContentView.swift
//  NaviSync
//
//  Created by Mrinal Raj on 7/29/26.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MultiMapView()
                .tabItem {
                    Label("Multi-Map", systemImage: "map.fill")
                }
                .tag(0)
            
            MeetingListView()
                .tabItem {
                    Label("Meetings", systemImage: "person.3.sequence.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .onAppear {
            locationManager.requestAuthorization()
        }
        .sheet(item: $deepLinkManager.activeInvitePayload) { payload in
            InviteResponseView(payload: payload) {
                deepLinkManager.activeInvitePayload = nil
                selectedTab = 0 // Switch to Multi-Map to show updated participants
            }
        }
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
