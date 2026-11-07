//
//  NaviSyncTests.swift
//  NaviSyncTests
//
//  Created by Mrinal Raj on 7/29/26.
//

import XCTest
import CoreLocation
@testable import NaviSync

final class NaviSyncTests: XCTestCase {

    func testLocationPointDistanceCalculation() {
        let charlotteCenter = LocationPoint(title: "Center", latitude: 35.2271, longitude: -80.8431)
        let southEnd = LocationPoint(title: "South End", latitude: 35.2120, longitude: -80.8580)
        
        let distanceMeters = charlotteCenter.distance(to: southEnd)
        XCTAssertGreaterThan(distanceMeters, 1000) // Should be ~1.8 km
        
        let formattedDist = southEnd.formattedDistance(to: charlotteCenter)
        XCTAssertTrue(formattedDist.contains("miles away") || formattedDist.contains("ft away"))
        
        let eta = southEnd.estimatedETA(to: charlotteCenter)
        XCTAssertFalse(eta.isEmpty)
    }
    
    @MainActor
    func testMeetingStoreCreationAndRSVP() {
        let store = MeetingStore()
        let initialCount = store.meetings.count
        
        let target = LocationPoint(title: "Coffee Hub", latitude: 35.2271, longitude: -80.8431)
        let meeting = store.createMeeting(
            title: "Test Sync",
            note: "Unit Test Note",
            scheduledDate: Date(),
            hostName: "Host X",
            hostContact: "+15550000",
            hostOrigin: "North Charlotte",
            targetLocation: target,
            initialInvitedNames: ["Friend 1"]
        )
        
        XCTAssertEqual(store.meetings.count, initialCount + 1)
        XCTAssertEqual(meeting.title, "Test Sync")
        XCTAssertEqual(meeting.pendingParticipants.count, 1)
        
        // Friend 1 accepts invitation
        let friendCoord = CLLocationCoordinate2D(latitude: 35.2200, longitude: -80.8400)
        store.respondToInvite(
            meetingID: meeting.id,
            participantName: "Friend 1",
            contactInfo: "+15551111",
            originLocationName: "Downtown",
            status: .accepted,
            coordinate: friendCoord
        )
        
        guard let updatedMeeting = store.meetings.first(where: { $0.id == meeting.id }) else {
            XCTFail("Meeting not found")
            return
        }
        
        XCTAssertEqual(updatedMeeting.acceptedParticipants.count, 2) // Host + Friend 1
        XCTAssertEqual(updatedMeeting.pendingParticipants.count, 0)
        
        let friend1 = updatedMeeting.acceptedParticipants.first(where: { $0.name == "Friend 1" })
        XCTAssertNotNil(friend1)
        XCTAssertEqual(friend1?.contactInfo, "+15551111")
        XCTAssertEqual(friend1?.originLocationName, "Downtown")
    }
    
    @MainActor
    func testDeepLinkManagerParsing() {
        let deepLinkManager = DeepLinkManager()
        
        let testURL = URL(string: "navisync://meeting?id=12345678-1234-1234-1234-123456789012&title=Joint%20Meeting&host=Person%20X&lat=35.2271&lng=-80.8431&place=Charlotte%20Plaza")!
        
        let success = deepLinkManager.handleURL(testURL)
        XCTAssertTrue(success)
        XCTAssertNotNil(deepLinkManager.activeInvitePayload)
        XCTAssertEqual(deepLinkManager.activeInvitePayload?.title, "Joint Meeting")
        XCTAssertEqual(deepLinkManager.activeInvitePayload?.hostName, "Person X")
        XCTAssertEqual(deepLinkManager.activeInvitePayload?.targetLocation.title, "Charlotte Plaza")
    }
    
    func testMeetingShareURLGeneration() {
        let target = LocationPoint(title: "Starbucks Plaza", latitude: 35.2271, longitude: -80.8431)
        let meeting = Meeting(
            title: "Coffee Chat",
            hostName: "Alex",
            hostContact: "+123456",
            hostOrigin: "South End",
            targetLocation: target
        )
        
        let shareURL = meeting.shareURL
        XCTAssertEqual(shareURL.scheme, "navisync")
        XCTAssertEqual(shareURL.host, "meeting")
        XCTAssertTrue(shareURL.absoluteString.contains("title=Coffee%20Chat"))
        
        let webURL = meeting.universalWebURL
        XCTAssertEqual(webURL.scheme, "https")
        XCTAssertEqual(webURL.host, "navisync.app")
    }
}
