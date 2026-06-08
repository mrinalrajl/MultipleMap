import Foundation
import CoreLocation
import MapKit
import SwiftUI

@MainActor
class MapViewModel: ObservableObject {
    @Published var currentUser: User = .mockSelf
    @Published var friends: [User] = User.mockFriends
    @Published var meetingLocation: MeetingLocation? = nil
    
    @Published var routeToMeeting: MKRoute? = nil
    @Published var selectedFriend: User? = nil
    
    // Calculate distance from friend to meeting location
    func distance(from friend: User) -> String {
        guard let friendLoc = friend.location, let meetLoc = meetingLocation?.coordinate else {
            return "Unknown"
        }
        let friendCLLoc = CLLocation(latitude: friendLoc.latitude, longitude: friendLoc.longitude)
        let meetCLLoc = CLLocation(latitude: meetLoc.latitude, longitude: meetLoc.longitude)
        
        let distanceMeters = friendCLLoc.distance(from: meetCLLoc)
        let distanceMiles = distanceMeters * 0.000621371
        
        return String(format: "%.1f mi", distanceMiles)
    }
    
    // Generate route from current user to meeting location
    func calculateRoute() async {
        guard let userLoc = currentUser.location, let meetLoc = meetingLocation?.coordinate else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLoc))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: meetLoc))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            if let route = response.routes.first {
                self.routeToMeeting = route
            }
        } catch {
            print("Failed to calculate route: \(error)")
        }
    }
    
    func setMeetingLocation(from url: URL) {
        // Parse a URL like multiplemaps://meet?lat=37.7596&lon=-122.4269&title=Park
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        var lat: Double?
        var lon: Double?
        var title = "Meeting Point"
        
        for item in queryItems {
            if item.name == "lat", let val = item.value, let d = Double(val) { lat = d }
            if item.name == "lon", let val = item.value, let d = Double(val) { lon = d }
            if item.name == "title", let val = item.value { title = val }
        }
        
        if let lat = lat, let lon = lon {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.meetingLocation = MeetingLocation(id: UUID(), title: title, coordinate: coord, inviteLink: url)
            Task {
                await calculateRoute()
            }
        }
    }
}
