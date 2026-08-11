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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(meetingStore)
                .environmentObject(deepLinkManager)
                .environmentObject(locationManager)
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
