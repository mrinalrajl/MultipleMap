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
    
    init(
        id: UUID = UUID(),
        name: String,
        contactInfo: String,
        originLocationName: String,
        status: ParticipantStatus = .pending,
        currentLocation: LocationPoint? = nil,
        respondedAt: Date? = nil,
        avatarColorName: String = "blue"
    ) {
        self.id = id
        self.name = name
        self.contactInfo = contactInfo
        self.originLocationName = originLocationName
        self.status = status
        self.currentLocation = currentLocation
        self.respondedAt = respondedAt
        self.avatarColorName = avatarColorName
    }
    
    func formattedDistance(to target: LocationPoint) -> String {
        guard let location = currentLocation else {
            return "Location unknown"
        }
        return location.formattedDistance(to: target)
    }
    
    func estimatedETA(to target: LocationPoint) -> String {
        guard let location = currentLocation else {
            return "N/A"
        }
        return location.estimatedETA(to: target)
    }
}
