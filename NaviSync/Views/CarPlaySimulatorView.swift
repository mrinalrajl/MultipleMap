//
//  CarPlaySimulatorView.swift
//  NaviSync
//
//  Apple CarPlay Automotive Navigation Cockpit UI.
//

import SwiftUI
import MapKit

#if canImport(UIKit)
import UIKit
#endif

struct CarPlaySimulatorView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .automatic
    @State private var is3DPerspective: Bool = true
    @State private var selectedParticipantIndex: Int = 0
    @State private var isManeuverBannerVisible: Bool = true
    @State private var showTripOverview: Bool = false
    
    var meeting: Meeting? {
        meetingStore.selectedMeeting ?? meetingStore.meetings.first
    }
    
    var activeParticipants: [Participant] {
        meeting?.acceptedParticipants ?? []
    }
    
    var currentFocusedParticipant: Participant? {
        guard !activeParticipants.isEmpty else { return nil }
        let idx = min(max(0, selectedParticipantIndex), activeParticipants.count - 1)
        return activeParticipants[idx]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let currentMeeting = meeting {
                // CarPlay Automotive Cockpit Display
                HStack(spacing: 0) {
                    // MARK: - Left CarPlay Automotive Dock Sidebar
                    CarPlayDockSidebar()
                        .frame(width: 64)
                        .background(Color(red: 0.08, green: 0.09, blue: 0.12))
                        .overlay(
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 1),
                            alignment: .trailing
                        )
                    
                    // MARK: - Main CarPlay Navigation Screen
                    ZStack(alignment: .topLeading) {
                        // 3D Navigation Map
                        CarPlay3DMapView(
                            meeting: currentMeeting,
                            position: $position,
                            is3DPerspective: is3DPerspective,
                            focusedParticipant: currentFocusedParticipant
                        )
                        .ignoresSafeArea()
                        
                        // Top-Left Maneuver Guidance Banner
                        if isManeuverBannerVisible {
                            CarPlayManeuverBanner(
                                meeting: currentMeeting,
                                focusedParticipant: currentFocusedParticipant
                            )
                            .padding(.top, 14)
                            .padding(.leading, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Top-Right Close Button
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black.opacity(0.75))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 14)
                                .padding(.trailing, 16)
                            }
                            Spacer()
                        }
                        
                        // Right Side Floating Map Controls
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                CarPlayFloatingControls(
                                    is3DPerspective: $is3DPerspective,
                                    onLocateVehicle: {
                                        recenterOnUserVehicle(meeting: currentMeeting)
                                    },
                                    onToggle3D: {
                                        is3DPerspective.toggle()
                                        updateCameraAngle(meeting: currentMeeting)
                                    },
                                    onOverviewFit: {
                                        fitAllParticipants(meeting: currentMeeting)
                                    }
                                )
                                .padding(.trailing, 16)
                                .padding(.bottom, 24)
                            }
                        }
                        
                        // Bottom-Left Floating Trip HUD Widget
                        VStack {
                            Spacer()
                            HStack(alignment: .bottom) {
                                CarPlayTripHUDWidget(
                                    meeting: currentMeeting,
                                    participant: currentFocusedParticipant,
                                    totalCount: activeParticipants.count,
                                    currentIndex: selectedParticipantIndex,
                                    onPrevious: {
                                        if !activeParticipants.isEmpty {
                                            selectedParticipantIndex = (selectedParticipantIndex - 1 + activeParticipants.count) % activeParticipants.count
                                            focusOnParticipant(activeParticipants[selectedParticipantIndex])
                                        }
                                    },
                                    onNext: {
                                        if !activeParticipants.isEmpty {
                                            selectedParticipantIndex = (selectedParticipantIndex + 1) % activeParticipants.count
                                            focusOnParticipant(activeParticipants[selectedParticipantIndex])
                                        }
                                    }
                                )
                                .padding(.leading, 16)
                                .padding(.bottom, 20)
                                
                                Spacer()
                                
                                // Bottom Center Road / Destination Pill
                                CarPlayRoadNamePill(
                                    destinationName: currentMeeting.targetLocation.title,
                                    isSimulating: meetingStore.isSimulatingLiveMovement,
                                    onToggleSimulation: {
                                        meetingStore.toggleLiveSimulation(isHost: false)
                                    }
                                )
                                .padding(.trailing, 80)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .aspectRatio(16/9, contentMode: .fit)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.8), radius: 24, x: 0, y: 12)
                .padding(.horizontal, 8)
                
            } else {
                ContentUnavailableView(
                    "No Meeting Active",
                    systemImage: "car.circle.fill",
                    description: Text("Select or create a joint meeting to launch CarPlay Cockpit view.")
                )
            }
        }
        #if !os(macOS)
        .navigationBarHidden(true)
        #endif
        .onAppear {
            if let m = meeting {
                recenterOnUserVehicle(meeting: m)
            }
        }
    }
    
    // MARK: - Camera Controls
    
    private func calculateBearing(from start: CLLocationCoordinate2D, to dest: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude * .pi / 180.0
        let lon1 = start.longitude * .pi / 180.0
        let lat2 = dest.latitude * .pi / 180.0
        let lon2 = dest.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        var degrees = radiansBearing * 180.0 / .pi
        if degrees < 0 { degrees += 360.0 }
        return degrees
    }
    
    private func recenterOnUserVehicle(meeting: Meeting) {
        let targetCoord = meeting.targetLocation.coordinate
        let startCoord = meeting.acceptedParticipants.first?.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: targetCoord.latitude - 0.02, longitude: targetCoord.longitude - 0.015)
        
        let center = CLLocationCoordinate2D(
            latitude: (startCoord.latitude + targetCoord.latitude) / 2.0,
            longitude: (startCoord.longitude + targetCoord.longitude) / 2.0
        )
        
        if is3DPerspective {
            let heading = calculateBearing(from: startCoord, to: targetCoord)
            position = .camera(
                MapCamera(
                    centerCoordinate: startCoord,
                    distance: 1200,
                    heading: heading,
                    pitch: 58
                )
            )
        } else {
            let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            position = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
    
    private func updateCameraAngle(meeting: Meeting) {
        if is3DPerspective {
            let targetCoord = meeting.targetLocation.coordinate
            let startCoord = meeting.acceptedParticipants.first?.currentLocation?.coordinate ?? targetCoord
            let heading = calculateBearing(from: startCoord, to: targetCoord)
            position = .camera(
                MapCamera(
                    centerCoordinate: startCoord,
                    distance: 1200,
                    heading: heading,
                    pitch: 58
                )
            )
        } else {
            fitAllParticipants(meeting: meeting)
        }
    }
    
    private func focusOnParticipant(_ participant: Participant) {
        guard let loc = participant.currentLocation else { return }
        if is3DPerspective {
            position = .camera(
                MapCamera(
                    centerCoordinate: loc.coordinate,
                    distance: 1200,
                    heading: 25,
                    pitch: 50
                )
            )
        } else {
            position = .region(
                MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                )
            )
        }
    }
    
    private func fitAllParticipants(meeting: Meeting) {
        var coordinates = [meeting.targetLocation.coordinate]
        for p in meeting.acceptedParticipants {
            if let loc = p.currentLocation {
                coordinates.append(loc.coordinate)
            }
        }
        let minLat = coordinates.map { $0.latitude }.min() ?? 35.2271
        let maxLat = coordinates.map { $0.latitude }.max() ?? 35.2271
        let minLng = coordinates.map { $0.longitude }.min() ?? -80.8431
        let maxLng = coordinates.map { $0.longitude }.max() ?? -80.8431
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2.0,
            longitude: (minLng + maxLng) / 2.0
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(abs(maxLat - minLat) * 1.6, 0.03),
            longitudeDelta: max(abs(maxLng - minLng) * 1.6, 0.03)
        )
        position = .region(MKCoordinateRegion(center: center, span: span))
    }
}

// MARK: - CarPlay 3D Map View
struct CarPlay3DMapView: View {
    let meeting: Meeting
    @Binding var position: MapCameraPosition
    let is3DPerspective: Bool
    let focusedParticipant: Participant?
    
    var body: some View {
        Map(position: $position) {
            // Target Spot Pin
            Annotation(meeting.targetLocation.title, coordinate: meeting.targetLocation.coordinate) {
                CarPlayDestinationPin(title: meeting.targetLocation.title)
            }
            
            // Route polyline from first participant to destination
            if let firstParticipant = meeting.acceptedParticipants.first,
               let loc = firstParticipant.currentLocation {
                
                // Real Road Waypoint polyline
                let routeCoords = RouteService.shared.route(for: firstParticipant.id)?.remainingCoordinates ?? generateRouteCoordinates(from: loc.coordinate, to: meeting.targetLocation.coordinate)
                MapPolyline(coordinates: routeCoords)
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.1, green: 0.8, blue: 0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                    )
                
                // Navigation Vehicle Chevron Arrow
                Annotation("Vehicle", coordinate: loc.coordinate) {
                    CarPlayVehicleChevron()
                }
            }
            
            // Multi-Friend Teardrop Avatar Pins
            ForEach(Array(meeting.acceptedParticipants.enumerated()), id: \.element.id) { index, participant in
                if let loc = participant.currentLocation {
                    Annotation(participant.name, coordinate: loc.coordinate) {
                        CarPlayFriendTeardropPin(
                            name: participant.name,
                            color: participantColor(for: index),
                            isSelected: participant.id == focusedParticipant?.id
                        )
                    }
                }
            }
        }
        .mapControlVisibility(.hidden)
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
    }
    
    private func generateRouteCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let midLat = (start.latitude + end.latitude) / 2.0
        let midLng = (start.longitude + end.longitude) / 2.0
        
        let p1 = CLLocationCoordinate2D(latitude: start.latitude + (midLat - start.latitude) * 0.4, longitude: start.longitude + 0.003)
        let p2 = CLLocationCoordinate2D(latitude: midLat, longitude: midLng)
        let p3 = CLLocationCoordinate2D(latitude: midLat + (end.latitude - midLat) * 0.6, longitude: end.longitude - 0.002)
        
        return [start, p1, p2, p3, end]
    }
    
    private func participantColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.55, blue: 0.15), // Amber Orange
            Color(red: 0.95, green: 0.25, blue: 0.50), // Hot Pink/Magenta
            Color(red: 0.15, green: 0.65, blue: 0.95), // Electric Cyan/Blue
            Color(red: 0.20, green: 0.80, blue: 0.55)  // Emerald Green
        ]
        return colors[index % colors.count]
    }
}

// MARK: - CarPlay Left Automotive Dock Sidebar
struct CarPlayDockSidebar: View {
    @State private var currentTimeString: String = "1:57"
    
    var body: some View {
        VStack(spacing: 16) {
            // Status & Time Row
            VStack(spacing: 4) {
                Text(currentTimeString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 3) {
                    Image(systemName: "cellularbars")
                        .font(.system(size: 8))
                    Text("5G")
                        .font(.system(size: 8, weight: .black))
                    Image(systemName: "battery.75")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white.opacity(0.75))
            }
            .padding(.top, 12)
            
            Spacer()
            
            // App Switcher Dock Icons
            VStack(spacing: 16) {
                // Apple Maps Icon
                CarPlayDockAppIcon(systemImage: "map.fill", color: Color.blue)
                
                // Music / Audio Icon (Spotify style)
                CarPlayDockAppIcon(systemImage: "play.circle.fill", color: Color.green)
                
                // Phone App Icon
                CarPlayDockAppIcon(systemImage: "phone.fill", color: Color.green)
            }
            
            Spacer()
            
            // CarPlay Dashboard Home Grid Icon
            Button {
                // Dashboard Grid Action
            } label: {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1).frame(width: 5, height: 5)
                        RoundedRectangle(cornerRadius: 1).frame(width: 5, height: 5)
                    }
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1).frame(width: 5, height: 5)
                        RoundedRectangle(cornerRadius: 1).frame(width: 5, height: 5)
                    }
                }
                .foregroundColor(.white.opacity(0.85))
                .padding(10)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 14)
        }
    }
}

struct CarPlayDockAppIcon: View {
    let systemImage: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 38, height: 38)
            
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(radius: 2)
    }
}

// MARK: - CarPlay Top-Left Green Maneuver Guidance Banner
struct CarPlayManeuverBanner: View {
    let meeting: Meeting
    let focusedParticipant: Participant?
    
    var route: LiveRoute? {
        if let id = focusedParticipant?.id {
            return RouteService.shared.route(for: id)
        }
        return RouteService.shared.activeRoute
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Maneuver Turn Arrow
            Image(systemName: route?.currentManeuver?.symbolName ?? "arrow.turn.up.right.fill")
                .font(.system(size: 26, weight: .black))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(route?.currentManeuver?.instruction ?? "NaviSync Driving")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(route?.formattedRemainingDistance ?? meeting.targetLocation.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green.opacity(0.9))
                    if let eta = route?.formattedRemainingETA {
                        Text("• \(eta)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.08, green: 0.48, blue: 0.24)) // Authentic CarPlay Dark Green
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}

// MARK: - CarPlay Teardrop Avatar Pin
struct CarPlayFriendTeardropPin: View {
    let name: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Pin Base Teardrop Shape
                Circle()
                    .fill(color)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: color.opacity(0.6), radius: 4)
                
                // Avatar Face / Icon
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                // Star / Status Badge
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 14, height: 14)
                            Image(systemName: "star.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 2, y: -2)
                    }
                    Spacer()
                }
                .frame(width: 42, height: 42)
            }
            
            // Pointer Stem
            Triangle()
                .fill(color)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - CarPlay Destination Target Pin
struct CarPlayDestinationPin: View {
    let title: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 4)
            
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Navigation Vehicle Chevron Arrow
struct CarPlayVehicleChevron: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 38, height: 38)
                .shadow(color: Color.blue.opacity(0.5), radius: 6)
            
            Image(systemName: "location.north.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
        }
    }
}

// MARK: - Floating Map Controls
struct CarPlayFloatingControls: View {
    @Binding var is3DPerspective: Bool
    let onLocateVehicle: () -> Void
    let onToggle3D: () -> Void
    let onOverviewFit: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onLocateVehicle) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .frame(width: 36, height: 36)
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            
            Button(action: onToggle3D) {
                ZStack {
                    Circle()
                        .fill(is3DPerspective ? Color.blue : Color(red: 0.15, green: 0.17, blue: 0.22))
                        .frame(width: 36, height: 36)
                    Image(systemName: "view.3d")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            
            Button(action: onOverviewFit) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.15, green: 0.17, blue: 0.22))
                        .frame(width: 36, height: 36)
                    Image(systemName: "map.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .shadow(color: Color.black.opacity(0.4), radius: 4)
    }
}

// MARK: - Bottom-Left Trip HUD Widget
struct CarPlayTripHUDWidget: View {
    let meeting: Meeting
    let participant: Participant?
    let totalCount: Int
    let currentIndex: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Previous Participant Button
            Button(action: onPrevious) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(6)
            }
            .buttonStyle(.plain)
            
            // ETA and Distance Center Metrics
            VStack(alignment: .center, spacing: 2) {
                if let p = participant {
                    Text(p.estimatedETA(to: meeting.targetLocation))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text(p.formattedDistance(to: meeting.targetLocation))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("• \(p.name)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.cyan)
                    }
                } else {
                    Text("18 min")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("4.75 mi • En Route")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Next Participant Button
            Button(action: onNext) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.12, green: 0.14, blue: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Bottom Center Road Name Pill
struct CarPlayRoadNamePill: View {
    let destinationName: String
    let isSimulating: Bool
    let onToggleSimulation: () -> Void
    
    var body: some View {
        Button(action: onToggleSimulation) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSimulating ? Color.green : Color.cyan)
                    .frame(width: 6, height: 6)
                
                Text(destinationName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(isSimulating ? "(Moving)" : "(Live)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSimulating ? .green : .cyan)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.9))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("CarPlay Automotive Cockpit") {
    CarPlaySimulatorView()
        .environmentObject(MeetingStore())
}
