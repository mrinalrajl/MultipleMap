//
//  NaviSyncApp.swift
//  NaviSync
//
//  Created by Mrinal Raj on 7/29/26.
//

import SwiftUI

@main
@MainActor
struct NaviSyncApp: App {
    @StateObject private var meetingStore = MeetingStore()
    @StateObject private var deepLinkManager = DeepLinkManager()
    @StateObject private var locationManager = LocationManager()
    
    @State private var appRouter = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appRouter.currentState {
                case .splash, .onboarding:
                    OnboardingFlowView()
                        .environment(appRouter)
                case .dashboard:
                    ContentView()
                        .environment(appRouter)
                }
            }
            .environmentObject(meetingStore)
            .environmentObject(deepLinkManager)
            .environmentObject(locationManager)
            // The tab bar, map, drawer and onboarding are designed dark-only;
            // lock the whole app to dark so every tab matches them.
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                _ = deepLinkManager.handleURL(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else { return }
                _ = deepLinkManager.handleURL(url)
            }
        }
    }
}
