//
//  MeetingActivityAttributes.swift
//  Shared between NaviSync and NaviSyncWidget
//

import Foundation
import ActivityKit

public struct MeetingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state data (updated in real-time)
        public var participantName: String
        public var distanceString: String
        public var etaString: String
        public var isArriving: Bool
        
        public init(participantName: String, distanceString: String, etaString: String, isArriving: Bool) {
            self.participantName = participantName
            self.distanceString = distanceString
            self.etaString = etaString
            self.isArriving = isArriving
        }
    }

    // Static data (set once when activity starts)
    public var meetingTitle: String
    public var targetLocationName: String
    
    public init(meetingTitle: String, targetLocationName: String) {
        self.meetingTitle = meetingTitle
        self.targetLocationName = targetLocationName
    }
}

