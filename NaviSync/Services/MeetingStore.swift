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
        if let current = selectedMeeting {
            Task {
                await RouteService.shared.fetchRoutes(for: current)
            }
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
        Task {
            await RouteService.shared.fetchRoutes(for: newMeeting)
        }
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
        Task {
            await RouteService.shared.fetchRoutes(for: meeting)
        }
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
    
    // MARK: - Live Movement Simulation & Lock Screen Live Activity
    
    @Published private var initialDistances: [UUID: Double] = [:]
    
    func startLockScreenLiveActivity(for meeting: Meeting? = nil, isHost: Bool = true) {
        let activeMeeting = meeting ?? meetings.first(where: { $0.id == selectedMeetingID }) ?? meetings.first
        guard let activeMeeting else { return }
        
        let participant = activeMeeting.acceptedParticipants.first ?? activeMeeting.participants.first
        guard let participant, participant.currentLocation != nil else { return }
        
        let route = RouteService.shared.route(for: participant.id)
        let distanceStr = route?.formattedRemainingDistance ?? participant.formattedDistance(to: activeMeeting.targetLocation)
        let etaStr = route?.formattedRemainingETA ?? participant.estimatedETA(to: activeMeeting.targetLocation)
        let destETAStr = route?.destinationETAString ?? {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: activeMeeting.scheduledDate)
        }()
        
        LiveActivityManager.shared.startTracking(
            meetingTitle: activeMeeting.title,
            targetLocation: activeMeeting.targetLocation.title,
            participantName: participant.name,
            distance: distanceStr,
            eta: etaStr,
            destinationETA: destETAStr,
            progress: route?.progress ?? 0.25,
            avatarImageName: "car.fill",
            isHost: isHost
        )
    }
    
    func stopLockScreenLiveActivity() {
        LiveActivityManager.shared.endTracking()
        if isSimulatingLiveMovement {
            stopSimulationTimer()
            isSimulatingLiveMovement = false
        }
    }
    
    func toggleLiveSimulation(isHost: Bool = true) {
        isSimulatingLiveMovement.toggle()
        if isSimulatingLiveMovement {
            if let activeMeeting = selectedMeeting {
                Task {
                    await RouteService.shared.fetchRoutes(for: activeMeeting)
                    self.startSimulationTimer()
                    self.startLockScreenLiveActivity(isHost: isHost)
                }
            } else {
                startSimulationTimer()
                startLockScreenLiveActivity(isHost: isHost)
            }
        } else {
            stopSimulationTimer()
            LiveActivityManager.shared.endTracking()
        }
    }
    
    func resetSimulation() {
        stopSimulationTimer()
        isSimulatingLiveMovement = false
        LiveActivityManager.shared.endTracking()
        setupSampleData()
        if let m = selectedMeeting {
            RouteService.shared.resetRoutes(for: m)
            Task {
                await RouteService.shared.fetchRoutes(for: m)
            }
        }
    }
    
    private func startSimulationTimer() {
        simulationTimer?.invalidate()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
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
        RouteService.shared.advanceSimulation(in: &meeting)
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
