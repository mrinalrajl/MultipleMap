//
//  MeetingStore.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import CoreLocation
import Combine
import ActivityKit

@MainActor
class MeetingStore: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var selectedMeetingID: UUID?
    @Published var isSimulatingLiveMovement: Bool = false
    
    private var simulationTimer: Timer?
    private let storageKey = "NaviSync_Saved_Meetings_v1"
    
    var selectedMeeting: Meeting? {
        get {
            guard let id = selectedMeetingID else { return meetings.first }
            return meetings.first(where: { $0.id == id }) ?? meetings.first
        }
        set {
            if let newValue = newValue, let index = meetings.firstIndex(where: { $0.id == newValue.id }) {
                meetings[index] = newValue
                saveToDisk()
            }
        }
    }
    
    init() {
        loadFromDisk()
        if meetings.isEmpty {
            setupSampleData()
        }
        if selectedMeetingID == nil, let first = meetings.first {
            selectedMeetingID = first.id
        }
    }
    
    // MARK: - Actions
    
    func createMeeting(
        title: String,
        note: String,
        scheduledDate: Date,
        hostName: String,
        hostContact: String,
        hostOrigin: String,
        targetLocation: LocationPoint,
        initialInvitedNames: [String] = []
    ) -> Meeting {
        let hostParticipant = Participant(
            name: "\(hostName) (Host)",
            contactInfo: hostContact,
            originLocationName: hostOrigin,
            status: .accepted,
            currentLocation: LocationPoint(
                title: "\(hostName)'s Origin",
                subtitle: hostOrigin,
                latitude: targetLocation.latitude + 0.025,
                longitude: targetLocation.longitude - 0.03
            ),
            respondedAt: Date(),
            avatarColorName: "purple"
        )
        
        var participantsList: [Participant] = [hostParticipant]
        
        let colorNames = ["orange", "green", "pink", "teal", "indigo"]
        for (idx, name) in initialInvitedNames.enumerated() {
            let p = Participant(
                name: name,
                contactInfo: "Pending Contact",
                originLocationName: "Pending Location",
                status: .pending,
                currentLocation: nil,
                respondedAt: nil,
                avatarColorName: colorNames[idx % colorNames.count]
            )
            participantsList.append(p)
        }
        
        let newMeeting = Meeting(
            title: title,
            note: note,
            scheduledDate: scheduledDate,
            hostName: hostName,
            hostContact: hostContact,
            hostOrigin: hostOrigin,
            targetLocation: targetLocation,
            participants: participantsList
        )
        
        meetings.insert(newMeeting, at: 0)
        selectedMeetingID = newMeeting.id
        saveToDisk()
        return newMeeting
    }
    
    func respondToInvite(
        meetingID: UUID,
        participantName: String,
        contactInfo: String,
        originLocationName: String,
        status: ParticipantStatus,
        coordinate: CLLocationCoordinate2D?
    ) {
        guard let index = meetings.firstIndex(where: { $0.id == meetingID }) else { return }
        var meeting = meetings[index]
        
        // Check if participant already exists by name or create a new one
        if let pIndex = meeting.participants.firstIndex(where: { $0.name.lowercased() == participantName.lowercased() || $0.status == .pending }) {
            meeting.participants[pIndex].name = participantName
            meeting.participants[pIndex].contactInfo = contactInfo
            meeting.participants[pIndex].originLocationName = originLocationName
            meeting.participants[pIndex].status = status
            meeting.participants[pIndex].respondedAt = Date()
            
            if let coord = coordinate {
                meeting.participants[pIndex].currentLocation = LocationPoint(
                    title: "\(participantName)'s Location",
                    subtitle: originLocationName,
                    coordinate: coord
                )
            }
        } else {
            let newLocation = coordinate.map { LocationPoint(title: "\(participantName)'s Location", subtitle: originLocationName, coordinate: $0) }
            let newP = Participant(
                name: participantName,
                contactInfo: contactInfo,
                originLocationName: originLocationName,
                status: status,
                currentLocation: newLocation,
                respondedAt: Date(),
                avatarColorName: "blue"
            )
            meeting.participants.append(newP)
        }
        
        meetings[index] = meeting
        saveToDisk()
    }
    
    func addPendingParticipant(meetingID: UUID, name: String, contact: String = "") {
        guard let index = meetings.firstIndex(where: { $0.id == meetingID }) else { return }
        let p = Participant(
            name: name,
            contactInfo: contact.isEmpty ? "Invite Pending" : contact,
            originLocationName: "Unknown",
            status: .pending,
            avatarColorName: ["orange", "cyan", "mint"].randomElement() ?? "cyan"
        )
        meetings[index].participants.append(p)
        saveToDisk()
    }
    
    func resendInvitation(to participant: Participant, in meeting: Meeting) -> String {
        let urlString = meeting.shareURL.absoluteString
        return "Hi \(participant.name)! Join us at \(meeting.title) at \(meeting.targetLocation.title). RSVP & see live locations here: \(urlString)"
    }
    
    // MARK: - Live Movement Simulation Mode
    
    func toggleLiveSimulation() {
        isSimulatingLiveMovement.toggle()
        if isSimulatingLiveMovement {
            startSimulationTimer()
            
            // Start Live Activity for the first accepted participant
            if let meetingID = selectedMeetingID,
               let meeting = meetings.first(where: { $0.id == meetingID }),
               let firstParticipant = meeting.acceptedParticipants.first,
               let loc = firstParticipant.currentLocation {
                
                LiveActivityManager.shared.startTracking(
                    meetingTitle: meeting.title,
                    targetLocation: meeting.targetLocation.title,
                    participantName: firstParticipant.name,
                    distance: loc.formattedDistance(to: meeting.targetLocation),
                    eta: loc.estimatedETA(to: meeting.targetLocation)
                )
            }
        } else {
            stopSimulationTimer()
            LiveActivityManager.shared.endTracking()
        }
    }
    
    private func startSimulationTimer() {
        simulationTimer?.invalidate()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.stepSimulation()
            }
        }
    }
    
    private func stopSimulationTimer() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    private func stepSimulation() {
        guard let meetingID = selectedMeetingID,
              let index = meetings.firstIndex(where: { $0.id == meetingID }) else { return }
        
        var meeting = meetings[index]
        let target = meeting.targetLocation
        
        for pIndex in 0..<meeting.participants.count {
            guard meeting.participants[pIndex].status == .accepted,
                  var currentLoc = meeting.participants[pIndex].currentLocation else { continue }
            
            let dLat = target.latitude - currentLoc.latitude
            let dLng = target.longitude - currentLoc.longitude
            
            // Move 5% closer to target each tick
            if abs(dLat) > 0.0001 || abs(dLng) > 0.0001 {
                currentLoc.latitude += dLat * 0.05
                currentLoc.longitude += dLng * 0.05
                meeting.participants[pIndex].currentLocation = currentLoc
                
                // Update Live Activity if it's the first accepted participant
                if meeting.participants[pIndex].id == meeting.acceptedParticipants.first?.id {
                    LiveActivityManager.shared.updateTracking(
                        participantName: meeting.participants[pIndex].name,
                        distance: currentLoc.formattedDistance(to: target),
                        eta: currentLoc.estimatedETA(to: target),
                        isArriving: abs(dLat) < 0.0005 && abs(dLng) < 0.0005
                    )
                }
            }
        }
        
        meetings[index] = meeting
    }
    
    // MARK: - Persistence
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(meetings)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save meetings: \(error)")
        }
    }
    
    private func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            meetings = try JSONDecoder().decode([Meeting].self, from: data)
        } catch {
            print("Failed to load meetings: \(error)")
        }
    }
    
    // MARK: - Sample Data
    
    private func setupSampleData() {
        // Sample location in Charlotte Uptown
        let targetSpot = LocationPoint(
            title: "Overstreet Mall Coffee Plaza",
            subtitle: "101 S Tryon St, Charlotte, NC",
            latitude: 35.2271,
            longitude: -80.8431
        )
        
        let friend1 = Participant(
            name: "Sarah Jenkins",
            contactInfo: "+1 (704) 555-0192",
            originLocationName: "South End, Charlotte",
            status: .accepted,
            currentLocation: LocationPoint(
                title: "Sarah's Car",
                subtitle: "S Tryon St",
                latitude: 35.2150,
                longitude: -80.8550
            ),
            respondedAt: Date().addingTimeInterval(-1800),
            avatarColorName: "blue"
        )
        
        let friend2 = Participant(
            name: "Marcus Vance",
            contactInfo: "marcus.v@example.com",
            originLocationName: "NoDa Arts District",
            status: .accepted,
            currentLocation: LocationPoint(
                title: "Marcus Transit",
                subtitle: "N Davidson St",
                latitude: 35.2420,
                longitude: -80.8120
            ),
            respondedAt: Date().addingTimeInterval(-900),
            avatarColorName: "green"
        )
        
        let friend3 = Participant(
            name: "David Kim",
            contactInfo: "+1 (704) 555-8831",
            originLocationName: "Ballantyne",
            status: .pending,
            currentLocation: nil,
            respondedAt: nil,
            avatarColorName: "orange"
        )
        
        let friend4 = Participant(
            name: "Elena Rostova",
            contactInfo: "elena@example.com",
            originLocationName: "Uptown North",
            status: .rejected,
            currentLocation: nil,
            respondedAt: Date().addingTimeInterval(-3600),
            avatarColorName: "pink"
        )
        
        let sampleMeeting = Meeting(
            title: "Weekend Team Sync & Coffee",
            note: "Let's catch up on the upcoming product launch! Grab coffee and review maps.",
            scheduledDate: Date().addingTimeInterval(3600),
            hostName: "Alex Rivera (Person X)",
            hostContact: "+1 (704) 555-0100",
            hostOrigin: "Dilworth, Charlotte",
            targetLocation: targetSpot,
            participants: [friend1, friend2, friend3, friend4]
        )
        
        meetings = [sampleMeeting]
        selectedMeetingID = sampleMeeting.id
        saveToDisk()
    }
}
