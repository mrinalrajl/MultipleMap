//
//  MeetingActivityAttributes.swift
//  NaviSync
//

import Foundation
import ActivityKit

public struct MeetingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state data (updated in real-time)
        public var participantName: String
        public var distanceString: String
        public var etaString: String
        public var destinationETA: String
        public var progress: Double // 0.0 to 1.0 (clamped)
        public var isArriving: Bool
        public var avatarImageName: String
        
        public init(
            participantName: String,
            distanceString: String,
            etaString: String,
            destinationETA: String = "18:50",
            progress: Double = 0.65,
            isArriving: Bool = false,
            avatarImageName: String = "person.crop.circle.fill"
        ) {
            self.participantName = participantName
            self.distanceString = distanceString
            self.etaString = etaString
            self.destinationETA = destinationETA
            self.progress = max(0.0, min(1.0, progress))
            self.isArriving = isArriving
            self.avatarImageName = avatarImageName
        }
    }

    // Static data (set once when activity starts)
    public var meetingTitle: String
    public var targetLocationName: String
    public var isHost: Bool
    
    public init(meetingTitle: String, targetLocationName: String, isHost: Bool = true) {
        self.meetingTitle = meetingTitle
        self.targetLocationName = targetLocationName
        self.isHost = isHost
    }
}
