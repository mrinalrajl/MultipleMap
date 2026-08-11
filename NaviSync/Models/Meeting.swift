//
//  Meeting.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import CoreLocation

struct Meeting: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var note: String
    var scheduledDate: Date
    var hostName: String
    var hostContact: String
    var hostOrigin: String
    var targetLocation: LocationPoint
    var participants: [Participant]
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        scheduledDate: Date = Date().addingTimeInterval(3600),
        hostName: String,
        hostContact: String,
        hostOrigin: String,
        targetLocation: LocationPoint,
        participants: [Participant] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.scheduledDate = scheduledDate
        self.hostName = hostName
        self.hostContact = hostContact
        self.hostOrigin = hostOrigin
        self.targetLocation = targetLocation
        self.participants = participants
        self.createdAt = createdAt
    }
    
    var shareURL: URL {
        var components = URLComponents()
        components.scheme = "navisync"
        components.host = "meeting"
        components.queryItems = [
            URLQueryItem(name: "id", value: id.uuidString),
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "host", value: hostName),
            URLQueryItem(name: "lat", value: String(targetLocation.latitude)),
            URLQueryItem(name: "lng", value: String(targetLocation.longitude)),
            URLQueryItem(name: "place", value: targetLocation.title)
        ]
        return components.url ?? URL(string: "navisync://meeting?id=\(id.uuidString)")!
    }
    
    var universalWebURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "navisync.app"
        components.path = "/m/\(id.uuidString)"
        components.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "host", value: hostName),
            URLQueryItem(name: "lat", value: String(targetLocation.latitude)),
            URLQueryItem(name: "lng", value: String(targetLocation.longitude)),
            URLQueryItem(name: "place", value: targetLocation.title)
        ]
        return components.url ?? URL(string: "https://navisync.app/m/\(id.uuidString)")!
    }
    
    var acceptedParticipants: [Participant] {
        participants.filter { $0.status == .accepted }
    }
    
    var pendingParticipants: [Participant] {
        participants.filter { $0.status == .pending }
    }
    
    var rejectedParticipants: [Participant] {
        participants.filter { $0.status == .rejected }
    }
}
