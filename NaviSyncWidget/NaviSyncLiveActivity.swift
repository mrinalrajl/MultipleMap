//
//  NaviSyncLiveActivity.swift
//  NaviSyncWidget
//
//  Live Activity & Dynamic Island UI for NaviSync meeting tracking.
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents

struct NaviSyncLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeetingActivityAttributes.self) { context in
            // MARK: - Lock Screen Live Activity Banner
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            // MARK: - Dynamic Island Configuration
            DynamicIsland {
                // Expanded Regions
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: context.attributes.isHost ? [.blue, .cyan] : [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 32, height: 32)
                            Image(systemName: context.attributes.isHost ? (context.state.avatarImageName.isEmpty ? "person.fill" : context.state.avatarImageName) : "location.north.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.isHost ? context.state.participantName : "Your Journey")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(context.attributes.meetingTitle)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    .padding(.leading, 4)
                    .padding(.top, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.etaString)
                            .font(.subheadline.weight(.black))
                            .foregroundColor(context.state.isArriving ? .green : .cyan)
                        Text(context.state.distanceString)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.trailing, 4)
                    .padding(.top, 4)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Mini route track in expanded dynamic island
                        RouteTimelineTrack(
                            progress: context.state.progress,
                            participantName: context.state.participantName,
                            isArriving: context.state.isArriving,
                            isCompact: true,
                            isHost: context.attributes.isHost
                        )
                        .padding(.horizontal, 4)
                        
                        HStack {
                            Label(context.attributes.targetLocationName, systemImage: "mappin.and.ellipse")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.75))
                                .lineLimit(1)
                            Spacer()
                            if context.state.isArriving {
                                Text("Arriving")
                                    .font(.caption2.bold())
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: context.attributes.isHost ? "person.circle.fill" : "location.north.circle.fill")
                        .font(.caption2)
                        .foregroundColor(context.attributes.isHost ? .cyan : .green)
                    Text(context.attributes.isHost ? context.state.participantName.prefix(4) : "Nav")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
            } compactTrailing: {
                Text(context.state.etaString)
                    .font(.caption2.bold())
                    .foregroundColor(context.state.isArriving ? .green : .cyan)
            } minimal: {
                Image(systemName: context.state.isArriving ? "flag.checkered" : (context.attributes.isHost ? "person.fill" : "location.north.fill"))
                    .foregroundColor(context.state.isArriving ? .green : .cyan)
            }
        }
    }
}

// MARK: - Lock Screen Banner View Matching Reference Design
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<MeetingActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            // Header Row: Avatar + Title + Status Pill
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: context.attributes.isHost ? [Color(red: 0.15, green: 0.45, blue: 0.95), Color(red: 0.1, green: 0.8, blue: 0.9)] : [Color.green, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: context.attributes.isHost ? "car.fill" : "location.north.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("Live Joint Navigation")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Circle()
                            .fill(context.state.isArriving ? Color.green : Color.cyan)
                            .frame(width: 5, height: 5)
                    }
                    
                    Text("\(context.attributes.meetingTitle) • \(context.attributes.targetLocationName)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Status Pill
                Text(context.state.isArriving ? "Arriving" : (context.attributes.isHost ? "En Route" : "Driving"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3.5)
                    .background(
                        context.state.isArriving ? Color.green.opacity(0.2) : Color.cyan.opacity(0.18)
                    )
                    .foregroundColor(context.state.isArriving ? .green : .cyan)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                context.state.isArriving ? Color.green.opacity(0.4) : Color.cyan.opacity(0.35),
                                lineWidth: 1
                            )
                    )
            }
            
            // Route Timeline Bar with Sliding Avatar Callout Pin
            RouteTimelineTrack(
                progress: context.state.progress,
                participantName: context.state.participantName,
                isArriving: context.state.isArriving,
                isCompact: false,
                isHost: context.attributes.isHost
            )
            .padding(.top, 4)
            .padding(.bottom, 2)
            
            // Bottom Metrics Row: Left ETA + Right Target Arrival
            HStack(alignment: .firstTextBaseline) {
                // Left side: Driver ETA & Distance
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.isHost ? "DRIVER ETA" : "ESTIMATED TIME")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(context.state.etaString)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(context.state.isArriving ? .green : .white)
                        
                        if !context.state.isArriving && !context.state.distanceString.isEmpty {
                            Text("• \(context.state.distanceString)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Right side: Target Destination Arrival Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DESTINATION")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(context.state.destinationETA)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("• Target")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                Color(red: 0.08, green: 0.09, blue: 0.13)
                LinearGradient(
                    colors: [Color.cyan.opacity(0.08), Color.blue.opacity(0.03), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }
}

// MARK: - Route Timeline Track with Sliding Pin
struct RouteTimelineTrack: View {
    let progress: Double // 0.0 to 1.0
    let participantName: String
    let isArriving: Bool
    let isCompact: Bool
    let isHost: Bool
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = max(geo.size.width, 100)
            let clampedProgress = max(0.04, min(0.96, progress))
            let currentX = totalWidth * CGFloat(clampedProgress)
            
            // Badge bounds clamping to prevent any horizontal edge overflow
            let badgeWidth: CGFloat = 80
            let badgeHalfWidth = badgeWidth / 2.0
            let clampedBadgeX = min(max(currentX, badgeHalfWidth), totalWidth - badgeHalfWidth)
            
            let trackY: CGFloat = isCompact ? 10 : 20
            
            ZStack(alignment: .leading) {
                // Background Track Line
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: totalWidth, height: isCompact ? 3 : 4)
                    .position(x: totalWidth / 2, y: trackY)
                
                // Traversed Track Glow
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                isHost ? Color(red: 0.2, green: 0.55, blue: 1.0) : Color.green,
                                isArriving ? Color.green : Color.cyan
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: currentX, height: isCompact ? 3 : 4)
                    .shadow(color: Color.cyan.opacity(0.5), radius: 3)
                    .position(x: currentX / 2, y: trackY)
                
                // Origin Terminal Node
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
                    .position(x: 4, y: trackY)
                
                // Destination Terminal Node
                Circle()
                    .fill(isArriving ? Color.green : Color.white.opacity(0.5))
                    .frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
                    .position(x: totalWidth - 4, y: trackY)
                
                if !isCompact {
                    // Speech Callout Badge (Safely clamped within totalWidth)
                    Text(isHost ? participantName : "You")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.14, green: 0.18, blue: 0.24))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .position(x: clampedBadgeX, y: 5)
                }
                
                // Moving Pin on Track
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isHost ? [Color.cyan, Color.blue] : [Color.green, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCompact ? 14 : 18, height: isCompact ? 14 : 18)
                        .shadow(color: (isHost ? Color.cyan : Color.green).opacity(0.6), radius: 3)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: isCompact ? 10 : 13, height: isCompact ? 10 : 13)
                    
                    Image(systemName: isHost ? "car.fill" : "location.north.fill")
                        .font(.system(size: isCompact ? 6 : 7.5, weight: .bold))
                        .foregroundColor(isHost ? Color(red: 0.1, green: 0.4, blue: 0.9) : Color.green)
                }
                .position(x: currentX, y: trackY)
            }
        }
        .frame(height: isCompact ? 20 : 32)
    }
}

// MARK: - AppIntents for Live Activity Actions
public struct EndTripIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "End Live Navigation"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        return .result()
    }
}

public struct NotifyHostIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Notify Host"
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Previews
#Preview("Lock Screen Live Activity - Host Mode", as: .content, using: MeetingActivityAttributes(meetingTitle: "Friends journey", targetLocationName: "Downtown Cafe", isHost: true)) {
    NaviSyncLiveActivity()
} contentStates: {
    MeetingActivityAttributes.ContentState(
        participantName: "Eve",
        distanceString: "03.4 km",
        etaString: "17:06",
        destinationETA: "18:50",
        progress: 0.65,
        isArriving: false,
        avatarImageName: "person.crop.circle.fill"
    )
}

#Preview("Lock Screen Live Activity - Guest Mode", as: .content, using: MeetingActivityAttributes(meetingTitle: "Friends journey", targetLocationName: "Downtown Cafe", isHost: false)) {
    NaviSyncLiveActivity()
} contentStates: {
    MeetingActivityAttributes.ContentState(
        participantName: "Eve",
        distanceString: "03.4 km",
        etaString: "17:06",
        destinationETA: "18:50",
        progress: 0.65,
        isArriving: false,
        avatarImageName: "person.crop.circle.fill"
    )
}
