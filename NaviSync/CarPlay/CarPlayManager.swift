//
//  CarPlayManager.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import MapKit

#if canImport(CarPlay)
import CarPlay

class CarPlayManager: NSObject, ObservableObject, CPInterfaceControllerDelegate {
    static let shared = CarPlayManager()
    
    var interfaceController: CPInterfaceController?
    var mapTemplate: CPMapTemplate?
    
    func setupInterfaceController(_ interfaceController: CPInterfaceController, meetingStore: MeetingStore) {
        self.interfaceController = interfaceController
        self.interfaceController?.delegate = self
        
        let mapTemplate = CPMapTemplate()
        self.mapTemplate = mapTemplate
        
        // Add CarPlay Action Bar Buttons
        let attendeesButton = CPBarButton(title: "Attendees") { [weak self] _ in
            self?.presentAttendeesList(meetingStore: meetingStore)
        }
        
        let simulateButton = CPBarButton(title: "Simulate") { _ in
            Task { @MainActor in
                meetingStore.toggleLiveSimulation(isHost: false)
            }
        }
        
        mapTemplate.trailingNavigationBarButtons = [attendeesButton, simulateButton]
        
        interfaceController.setRootTemplate(mapTemplate, animated: true, completion: nil)
        
        updateCarPlayMap(meetingStore: meetingStore)
    }
    
    func updateCarPlayMap(meetingStore: MeetingStore) {
        Task { @MainActor in
            guard let meeting = meetingStore.selectedMeeting, let mapTemplate = self.mapTemplate else { return }
            
            let targetPoint = MKPointAnnotation()
            targetPoint.coordinate = meeting.targetLocation.coordinate
            targetPoint.title = "Target: \(meeting.targetLocation.title)"
            
            mapTemplate.showTripPreviews([], selectedTrip: nil, textConfiguration: nil)
        }
    }
    
    func presentAttendeesList(meetingStore: MeetingStore) {
        Task { @MainActor in
            guard let meeting = meetingStore.selectedMeeting, let interfaceController = self.interfaceController else { return }
            
            var items: [CPListItem] = []
            
            // Accepted Attendees Section
            for p in meeting.acceptedParticipants {
                let distText = p.formattedDistance(to: meeting.targetLocation)
                let etaText = p.estimatedETA(to: meeting.targetLocation)
                
                let item = CPListItem(
                    text: "\(p.name) (Accepted)",
                    detailText: "From: \(p.originLocationName) • \(distText) • ETA: \(etaText)"
                )
                items.append(item)
            }
            
            // Pending Attendees Section with Send Invite action
            for p in meeting.pendingParticipants {
                let item = CPListItem(
                    text: "\(p.name) (Pending)",
                    detailText: "Tap to send invite link via SMS/Message"
                )
                item.handler = { _, completion in
                    print("CarPlay: Sending invite ping to \(p.name)")
                    completion()
                }
                items.append(item)
            }
            
            let section = CPListSection(items: items, header: "Meeting Participants", sectionIndexTitle: "P")
            let listTemplate = CPListTemplate(title: "Participants & Distance", sections: [section])
            
            interfaceController.pushTemplate(listTemplate, animated: true, completion: nil)
        }
    }
}
#endif
