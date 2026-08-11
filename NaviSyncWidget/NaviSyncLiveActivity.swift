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
            // MARK: - Lock Screen / Banner UI
            VStack(spacing: 8) {
                // Header Bar: Meeting Title, Target Location & Status Badge
                HStack(alignment: .center, spacing: 10) {
                    // App/Location Icon Badge
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.meetingTitle)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.cyan)
                            Text(context.attributes.targetLocationName)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    if context.state.isArriving {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Arriving Soon")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    } else {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 6, height: 6)
                            Text("En Route")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                // Hero Section: ETA, Route Progress Bar & Distance
                HStack(alignment: .center, spacing: 14) {
                    // Left Column: Big ETA Metric
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ETA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text(context.state.etaString.replacingOccurrences(of: " mins", with: "").replacingOccurrences(of: " min", with: ""))
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(context.state.isArriving ? .green : .orange)
                            
                            Text("min")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(context.state.isArriving ? .green.opacity(0.8) : .orange.opacity(0.8))
                        }
                    }
                    .frame(width: 65, alignment: .leading)
                    
                    // Right Column: Progress bar & Distance
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "car.fill")
                                .font(.caption)
                                .foregroundColor(.cyan)
                            
                            // Visual Route Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 4)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.cyan, context.state.isArriving ? .green : .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: context.state.isArriving ? geo.size.width : geo.size.width * 0.65, height: 4)
                                }
                                .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .frame(height: 12)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text(context.state.distanceString)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(context.state.participantName)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                
                // Interactive Action Buttons (iOS 17+)
                if #available(iOS 17.0, *) {
                    HStack(spacing: 12) {
                        // End Trip (Secondary Action)
                        Button(intent: EndTripIntent()) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.subheadline)
                                Text("End Trip")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.red.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.red.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Notify Host (Primary Action)
                        Button(intent: NotifyHostIntent()) {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.fill")
                                    .font(.subheadline)
                                Text("Notify Host")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.13, blue: 0.20),
                        Color(red: 0.08, green: 0.09, blue: 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .activityBackgroundTint(Color(red: 0.10, green: 0.11, blue: 0.16))
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            // MARK: - Dynamic Island
            DynamicIsland {
                // Expanded Regions
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "car.circle.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.participantName)
                                .font(.headline)
                                .lineLimit(1)
                            Text(context.attributes.meetingTitle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.top, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.distanceString)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(context.state.isArriving ? .green : .cyan)
                            .lineLimit(1)
                        
                        Text(context.state.etaString)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            Text(context.attributes.targetLocationName)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if context.state.isArriving {
                                Text("Arriving!")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Interactive Buttons for Dynamic Island
                        if #available(iOS 17.0, *) {
                            HStack(spacing: 12) {
                                Button(intent: EndTripIntent()) {
                                    Text("End Trip")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                
                                Button(intent: NotifyHostIntent()) {
                                    Text("Notify Host")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
            } compactLeading: {
                // Compact Leading (pill left side)
                HStack(spacing: 4) {
                    Image(systemName: "car.fill")
                        .foregroundColor(context.state.isArriving ? .green : .cyan)
                    Text(context.state.distanceString.replacingOccurrences(of: " miles", with: "mi").replacingOccurrences(of: " mile", with: "mi"))
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .padding(.leading, 4)
                
            } compactTrailing: {
                // Compact Trailing (pill right side)
                Text(context.state.isArriving ? "Here" : context.state.etaString.replacingOccurrences(of: " min", with: "m").replacingOccurrences(of: "s", with: ""))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(context.state.isArriving ? .green : .orange)
                    .padding(.trailing, 4)
                
            } minimal: {
                // Minimal (smallest representation)
                Image(systemName: "car.fill")
                    .foregroundColor(context.state.isArriving ? .green : .cyan)
            }
        }
    }
}

@available(iOS 16.1, *)
public struct EndTripIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "End Trip"
    public init() {}
    public func perform() async throws -> some IntentResult {
        return .result()
    }
}

@available(iOS 16.1, *)
public struct NotifyHostIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Notify Host"
    public init() {}
    public func perform() async throws -> some IntentResult {
        return .result()
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Lock Screen Live Activity", as: .content, using: MeetingActivityAttributes(meetingTitle: "Joint Coffee", targetLocationName: "Uptown City Center")) {
    NaviSyncLiveActivity()
} contentStates: {
    MeetingActivityAttributes.ContentState(
        participantName: "Alex Rivera (Host)",
        distanceString: "1.5 miles away",
        etaString: "4 mins",
        isArriving: false
    )
    MeetingActivityAttributes.ContentState(
        participantName: "Alex Rivera (Host)",
        distanceString: "0.2 miles away",
        etaString: "1 min",
        isArriving: true
    )
}
#endif
