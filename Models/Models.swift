import Foundation
import CoreLocation

struct User: Identifiable, Equatable {
    let id: UUID
    var name: String
    var location: CLLocationCoordinate2D?
    var isSelf: Bool = false
    var imageName: String? = nil
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct MeetingLocation: Identifiable {
    let id: UUID
    var title: String
    var coordinate: CLLocationCoordinate2D
    var inviteLink: URL?
    var icon: String? = "📍"
    var sharingEndTime: Date? = nil
}

// Mock Data
extension User {
    static let mockSelf = User(id: UUID(), name: "Me", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), isSelf: true, imageName: "person.circle.fill")
    
    static let mockFriends = [
        User(id: UUID(), name: "Alice", location: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4180), imageName: "person.crop.circle.badge.checkmark"),
        User(id: UUID(), name: "Bob", location: CLLocationCoordinate2D(latitude: 37.7730, longitude: -122.4200), imageName: "person.crop.circle.dashed"),
        User(id: UUID(), name: "Charlie", location: CLLocationCoordinate2D(latitude: 37.7800, longitude: -122.4150), imageName: "person.crop.circle.fill")
    ]
}

extension MeetingLocation {
    static let mockMeeting = MeetingLocation(
        id: UUID(),
        title: "Joe's Pizza",
        coordinate: CLLocationCoordinate2D(latitude: 37.7596, longitude: -122.4269),
        inviteLink: URL(string: "multiplemaps://meet?id=123&lat=37.7596&lon=-122.4269&icon=🍕"),
        icon: "🍕",
        sharingEndTime: Date().addingTimeInterval(2 * 3600) // 2 hours from now
    )
}
