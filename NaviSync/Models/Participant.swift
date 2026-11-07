//
//  Participant.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import CoreLocation

enum ParticipantStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Declined"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
}

struct Participant: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var contactInfo: String
    var originLocationName: String // "where he is from"
    var status: ParticipantStatus
    var currentLocation: LocationPoint?
    var respondedAt: Date?
    var avatarColorName: String
    var routeDistanceMeters: CLLocationDistance?
    var routeTravelTimeSeconds: TimeInterval?
    var currentInstruction: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        contactInfo: String,
        originLocationName: String,
        status: ParticipantStatus = .pending,
        currentLocation: LocationPoint? = nil,
        respondedAt: Date? = nil,
        avatarColorName: String = "blue",
        routeDistanceMeters: CLLocationDistance? = nil,
        routeTravelTimeSeconds: TimeInterval? = nil,
        currentInstruction: String? = nil
    ) {
        self.id = id
        self.name = name
        self.contactInfo = contactInfo
        self.originLocationName = originLocationName
        self.status = status
        self.currentLocation = currentLocation
        self.respondedAt = respondedAt
        self.avatarColorName = avatarColorName
        self.routeDistanceMeters = routeDistanceMeters
        self.routeTravelTimeSeconds = routeTravelTimeSeconds
        self.currentInstruction = currentInstruction
    }
    
    func formattedDistance(to target: LocationPoint) -> String {
        if let meters = routeDistanceMeters {
            let miles = meters / 1609.34
            if miles < 0.1 {
                let feet = meters * 3.28084
                return String(format: "%.0f ft", feet)
            } else {
                return String(format: "%.1f mi", miles)
            }
        }
        guard let location = currentLocation else {
            return "Location unknown"
        }
        return location.formattedDistance(to: target)
    }
    
    func estimatedETA(to target: LocationPoint) -> String {
        if let seconds = routeTravelTimeSeconds {
            let minutes = Int(ceil(seconds / 60.0))
            if minutes <= 1 {
                return "Arriving now"
            } else if minutes < 60 {
                return "\(minutes) min"
            } else {
                let hrs = minutes / 60
                let mins = minutes % 60
                return "\(hrs)h \(mins)m"
            }
        }
        guard let location = currentLocation else {
            return "N/A"
        }
        return location.estimatedETA(to: target)
    }
}
