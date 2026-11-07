//
//  LiveActivityManager.swift
//  NaviSync
//

import Foundation
import ActivityKit

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    @Published var currentActivityId: String?
    @Published var isLiveActivityActive: Bool = false
    
    var isEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func startTracking(
        meetingTitle: String,
        targetLocation: String,
        participantName: String,
        distance: String,
        eta: String,
        destinationETA: String = "18:50",
        progress: Double = 0.25,
        avatarImageName: String = "person.crop.circle.fill",
        isHost: Bool = true
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        // If an existing activity is active, end it first before starting a new one
        if currentActivityId != nil {
            endTracking()
        }
        
        let attributes = MeetingActivityAttributes(meetingTitle: meetingTitle, targetLocationName: targetLocation, isHost: isHost)
        let initialContentState = MeetingActivityAttributes.ContentState(
            participantName: participantName,
            distanceString: distance,
            etaString: eta,
            destinationETA: destinationETA,
            progress: progress,
            isArriving: false,
            avatarImageName: avatarImageName
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            currentActivityId = activity.id
            isLiveActivityActive = true
            print("Started Live Activity on Lock Screen: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateTracking(
        participantName: String,
        distance: String,
        eta: String,
        destinationETA: String = "18:50",
        progress: Double = 0.5,
        isArriving: Bool = false,
        avatarImageName: String = "person.crop.circle.fill"
    ) {
        guard let activityId = currentActivityId,
              let activity = Activity<MeetingActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            return
        }
        
        let updatedState = MeetingActivityAttributes.ContentState(
            participantName: participantName,
            distanceString: distance,
            etaString: eta,
            destinationETA: destinationETA,
            progress: progress,
            isArriving: isArriving,
            avatarImageName: avatarImageName
        )
        
        Task {
            await activity.update(
                ActivityContent<MeetingActivityAttributes.ContentState>(
                    state: updatedState,
                    staleDate: nil
                )
            )
        }
    }
    
    func endTracking() {
        guard let activityId = currentActivityId,
              let activity = Activity<MeetingActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            isLiveActivityActive = false
            currentActivityId = nil
            return
        }
        
        Task {
            await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )
            currentActivityId = nil
            isLiveActivityActive = false
        }
    }
}
