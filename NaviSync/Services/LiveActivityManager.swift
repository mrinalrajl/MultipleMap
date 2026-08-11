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
    
    func startTracking(meetingTitle: String, targetLocation: String, participantName: String, distance: String, eta: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let attributes = MeetingActivityAttributes(meetingTitle: meetingTitle, targetLocationName: targetLocation)
        let initialContentState = MeetingActivityAttributes.ContentState(
            participantName: participantName,
            distanceString: distance,
            etaString: eta,
            isArriving: false
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            currentActivityId = activity.id
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateTracking(participantName: String, distance: String, eta: String, isArriving: Bool = false) {
        guard let activityId = currentActivityId,
              let activity = Activity<MeetingActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            return
        }
        
        let updatedState = MeetingActivityAttributes.ContentState(
            participantName: participantName,
            distanceString: distance,
            etaString: eta,
            isArriving: isArriving
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
            return
        }
        
        Task {
            await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )
            currentActivityId = nil
        }
    }
}
