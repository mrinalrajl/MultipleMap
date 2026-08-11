//
//  DeepLinkManager.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import Foundation
import CoreLocation

struct InvitePayload: Identifiable, Equatable {
    var id: UUID
    var title: String
    var hostName: String
    var targetLocation: LocationPoint
}

@MainActor
class DeepLinkManager: ObservableObject {
    @Published var activeInvitePayload: InvitePayload?
    
    func handleURL(_ url: URL) -> Bool {
        print("Handling incoming URL: \(url.absoluteString)")
        
        // Handle navisync://meeting?id=... or https://navisync.app/m/...
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        let isNaviSyncScheme = url.scheme?.lowercased() == "navisync"
        let isUniversalLink = url.host?.lowercased() == "navisync.app"
        
        guard isNaviSyncScheme || isUniversalLink else {
            return false
        }
        
        var queryDict: [String: String] = [:]
        components.queryItems?.forEach { item in
            queryDict[item.name] = item.value
        }
        
        var idString: String? = queryDict["id"]
        
        if isUniversalLink, url.pathComponents.count >= 2 {
            // Path is usually "/", "m", "uuid"
            idString = url.pathComponents.last
        }
        
        let finalIDString = idString ?? UUID().uuidString
        let id = UUID(uuidString: finalIDString) ?? UUID()
        let title = queryDict["title"] ?? "Joint Meeting Spot"
        let hostName = queryDict["host"] ?? "Person X"
        let latStr = queryDict["lat"] ?? "35.2271"
        let lngStr = queryDict["lng"] ?? "-80.8431"
        let placeName = queryDict["place"] ?? "Target Location"
        
        let lat = Double(latStr) ?? 35.2271
        let lng = Double(lngStr) ?? -80.8431
        
        let targetLocation = LocationPoint(
            title: placeName,
            subtitle: "Meeting Destination",
            latitude: lat,
            longitude: lng
        )
        
        self.activeInvitePayload = InvitePayload(
            id: id,
            title: title,
            hostName: hostName,
            targetLocation: targetLocation
        )
        
        return true
    }
}
