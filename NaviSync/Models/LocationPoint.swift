//
//  LocationPoint.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import CoreLocation

struct LocationPoint: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), title: String, subtitle: String? = nil, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(id: UUID = UUID(), title: String, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func clLocation() -> CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func distance(to other: LocationPoint) -> CLLocationDistance {
        clLocation().distance(from: other.clLocation())
    }
    
    func formattedDistance(to target: LocationPoint) -> String {
        let meters = distance(to: target)
        let miles = meters / 1609.34
        if miles < 0.1 {
            let feet = meters * 3.28084
            return String(format: "%.0f ft away", feet)
        } else {
            return String(format: "%.1f miles away", miles)
        }
    }
    
    func estimatedETA(to target: LocationPoint, speedMph: Double = 30.0) -> String {
        let meters = distance(to: target)
        let miles = meters / 1609.34
        let hours = miles / speedMph
        let minutes = Int(ceil(hours * 60))
        if minutes <= 1 {
            return "Arriving now"
        } else if minutes < 60 {
            return "\(minutes) mins"
        } else {
            let hrs = minutes / 60
            let mins = minutes % 60
            return "\(hrs)h \(mins)m"
        }
    }
}
