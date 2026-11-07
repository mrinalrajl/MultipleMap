//
//  MultiMapView.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import SwiftUI
import MapKit

#if canImport(UIKit)
import UIKit
#endif

struct MultiMapView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject private var routeService = RouteService.shared
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedParticipantID: Participant.ID?
    @State private var isBottomDrawerExpanded = true
    @State private var is3DDriverView = true
    
    var meeting: Meeting? {
        meetingStore.selectedMeeting
    }
    
    var activeRoute: LiveRoute? {
        if let id = selectedParticipantID {
            return routeService.route(for: id)
        }
        return routeService.activeRoute
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let currentMeeting = meeting {
                    // Modern iOS 17 Map View
                    Map(position: $position, selection: $selectedParticipantID) {
                        // 1. Target Destination Pin
                        Annotation(currentMeeting.targetLocation.title, coordinate: currentMeeting.targetLocation.coordinate) {
                            DestinationAnnotationView(title: currentMeeting.targetLocation.title)
                        }
                        .annotationTitles(.hidden)
                        
                        // 2. Real Road Polylines for Accepted Participants
                        ForEach(currentMeeting.acceptedParticipants) { participant in
                            let isSelected = (participant.id == (selectedParticipantID ?? routeService.activeParticipantID))
                            let route = routeService.route(for: participant.id)
                            let coords = route?.remainingCoordinates ?? {
                                if let loc = participant.currentLocation {
                                    return [loc.coordinate, currentMeeting.targetLocation.coordinate]
                                }
                                return []
                            }()
                            
                            if !coords.isEmpty {
                                if isSelected {
                                    // Outer Route Glow
                                    MapPolyline(coordinates: coords)
                                        .stroke(Color.blue.opacity(0.35), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                                    
                                    // Inner Crisp Driving Path
                                    MapPolyline(coordinates: coords)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.blue, Color.cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                                        )
                                } else {
                                    // Ambient Route for other participants
                                    MapPolyline(coordinates: coords)
                                        .stroke(
                                            participantColor(participant.avatarColorName).opacity(0.65),
                                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                                        )
                                }
                            }
                        }
                        
                        // 3. Accepted Participants Markers with Live Distance Badges
                        ForEach(currentMeeting.acceptedParticipants) { participant in
                            if let loc = participant.currentLocation {
                                let isSelected = (participant.id == (selectedParticipantID ?? routeService.activeParticipantID))
                                let route = routeService.route(for: participant.id)
                                
                                Annotation(participant.name, coordinate: loc.coordinate) {
                                    ParticipantMapMarkerView(
                                        participant: participant,
                                        route: route,
                                        isSelected: isSelected,
                                        color: participantColor(participant.avatarColorName)
                                    )
                                }
                                .tag(participant.id)
                            }
                        }
                    }
                    .mapControlVisibility(.hidden)
                    .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant, .cafe, .parking]), showsTraffic: true))
                    .onChange(of: selectedParticipantID) { _, newId in
                        if let newId = newId {
                            routeService.activeParticipantID = newId
                            withAnimation(.spring) {
                                isBottomDrawerExpanded = true
                            }
                            if let r = routeService.route(for: newId) {
                                focusOnRoute(r)
                            }
                        }
                    }
                    .onChange(of: activeRoute?.remainingCoordinates.first?.latitude) { _, _ in
                        if is3DDriverView, let route = activeRoute, !route.isArrived, meetingStore.isSimulatingLiveMovement {
                            focusOnRoute(route, animated: true)
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    
                    // Layer 1: Top Navigation Guidance Card & Floating Controls
                    VStack(spacing: 8) {
                        if let route = activeRoute {
                            TurnByTurnGuidanceCard(
                                route: route,
                                isSimulating: meetingStore.isSimulatingLiveMovement
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Floating Controls Bar (Clean, Non-Overlapping Glassmorphism Stack)
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 8) {
                                // Segmented 2D / 3D Mode Selector
                                HStack(spacing: 0) {
                                    Button {
                                        if is3DDriverView {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                is3DDriverView = false
                                                updateMapCameraToFitAll()
                                            }
                                        }
                                    } label: {
                                        Text("2D")
                                            .font(.system(size: 11, weight: !is3DDriverView ? .bold : .semibold, design: .rounded))
                                            .foregroundColor(!is3DDriverView ? .white : .white.opacity(0.6))
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 5)
                                            .background(!is3DDriverView ? Color.blue : Color.clear)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Button {
                                        if !is3DDriverView {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                is3DDriverView = true
                                                if let r = activeRoute {
                                                    focusOnRoute(r)
                                                } else {
                                                    updateMapCameraToFitAll()
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 3) {
                                            Image(systemName: "cube.transparent")
                                                .font(.system(size: 10, weight: .bold))
                                            Text("3D")
                                                .font(.system(size: 11, weight: is3DDriverView ? .bold : .semibold, design: .rounded))
                                        }
                                        .foregroundColor(is3DDriverView ? .white : .white.opacity(0.6))
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(is3DDriverView ? Color.blue : Color.clear)
                                        .clipShape(Capsule())
                                    }
                                }
                                .padding(2)
                                .background(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.9))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                                
                                // Recenter All Camera Button
                                Button {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        if let r = activeRoute {
                                            focusOnRoute(r)
                                        } else {
                                            updateMapCameraToFitAll()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "location.viewfinder")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(9)
                                        .background(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.9))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                                }
                                
                                // Unified Simulate / Pause / Reset Driving Button
                                Button {
                                    if activeRoute?.isArrived == true {
                                        meetingStore.resetSimulation()
                                    } else {
                                        meetingStore.toggleLiveSimulation()
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        if activeRoute?.isArrived == true {
                                            Image(systemName: "arrow.counterclockwise")
                                                .font(.system(size: 10, weight: .bold))
                                            Text("Reset")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                        } else {
                                            Image(systemName: meetingStore.isSimulatingLiveMovement ? "pause.fill" : "play.fill")
                                                .font(.system(size: 10, weight: .bold))
                                            Text(meetingStore.isSimulatingLiveMovement ? "Pause" : "Simulate")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                        }
                                    }
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 7)
                                    .background(
                                        activeRoute?.isArrived == true 
                                            ? Color.orange 
                                            : (meetingStore.isSimulatingLiveMovement ? Color.green : Color.blue)
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                                }
                            }
                            .padding(.trailing, 16)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    // Layer 2: Floating in-view Bottom Drawer (Elevated safely ABOVE the bottom menu bar!)
                    VStack {
                        Spacer()
                        inViewBottomDrawer(for: currentMeeting)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                } else {
                    ContentUnavailableView("No Meeting Selected", systemImage: "map.fill", description: Text("Create or select a joint meeting to view multi-map tracking."))
                }
            }
            .navigationTitle("Multi-Map Live")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(meetingStore.meetings) { m in
                            Button {
                                meetingStore.selectedMeetingID = m.id
                                Task {
                                    await routeService.fetchRoutes(for: m)
                                    updateMapCameraToFitAll()
                                }
                            } label: {
                                Label(m.title, systemImage: m.id == meetingStore.selectedMeetingID ? "checkmark" : "map")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                if let currentMeeting = meeting {
                    await routeService.fetchRoutes(for: currentMeeting)
                    if is3DDriverView, let r = activeRoute {
                        focusOnRoute(r)
                    } else {
                        updateMapCameraToFitAll()
                    }
                }
            }
            .onAppear {
                #if canImport(UIKit)
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithDefaultBackground()
                navBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                navBarAppearance.backgroundColor = UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 0.85)
                navBarAppearance.titleTextAttributes = [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 17, weight: .bold)
                ]
                UINavigationBar.appearance().standardAppearance = navBarAppearance
                UINavigationBar.appearance().compactAppearance = navBarAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
                #endif
            }
        }
    }
    
    // MARK: - Camera Control Methods
    
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
    
    private func updateMapCameraToFitAll() {
        guard let currentMeeting = meeting else { return }
        var coordinates = [currentMeeting.targetLocation.coordinate]
        for p in currentMeeting.acceptedParticipants {
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
        
        if is3DDriverView {
            let heading = calculateBearing(from: center, to: currentMeeting.targetLocation.coordinate)
            let maxSpanDelta = max(abs(maxLat - minLat), abs(maxLng - minLng))
            let altitude = max(maxSpanDelta * 111000 * 1.6, 2500)
            withAnimation(.easeInOut(duration: 0.6)) {
                position = .camera(
                    MapCamera(
                        centerCoordinate: center,
                        distance: altitude,
                        heading: heading,
                        pitch: 55
                    )
                )
            }
        } else {
            let span = MKCoordinateSpan(
                latitudeDelta: max(abs(maxLat - minLat) * 1.55, 0.04),
                longitudeDelta: max(abs(maxLng - minLng) * 1.55, 0.04)
            )
            withAnimation(.easeInOut(duration: 0.6)) {
                position = .region(MKCoordinateRegion(center: center, span: span))
            }
        }
    }
    
    private func focusOnRoute(_ route: LiveRoute, animated: Bool = true) {
        let currentCoord = route.remainingCoordinates.first ?? route.startCoordinate
        let destinationCoord = route.destinationCoordinate
        
        if is3DDriverView {
            // Calculate forward road bearing towards upcoming waypoint (lookahead 3 points for stability)
            let lookaheadIdx = min(3, max(0, route.remainingCoordinates.count - 1))
            let nextCoord = (lookaheadIdx > 0 && route.remainingCoordinates.count > lookaheadIdx)
                ? route.remainingCoordinates[lookaheadIdx]
                : destinationCoord
            let heading = calculateBearing(from: currentCoord, to: nextCoord)
            
            let camera = MapCamera(
                centerCoordinate: currentCoord,
                distance: 750,
                heading: heading,
                pitch: 62
            )
            if animated {
                withAnimation(.easeInOut(duration: 0.6)) {
                    position = .camera(camera)
                }
            } else {
                position = .camera(camera)
            }
        } else {
            var coords = route.remainingCoordinates
            if coords.isEmpty { coords = [currentCoord, route.destinationCoordinate] }
            
            let minLat = coords.map { $0.latitude }.min() ?? currentCoord.latitude
            let maxLat = coords.map { $0.latitude }.max() ?? currentCoord.latitude
            let minLng = coords.map { $0.longitude }.min() ?? currentCoord.longitude
            let maxLng = coords.map { $0.longitude }.max() ?? currentCoord.longitude
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2.0,
                longitude: (minLng + maxLng) / 2.0
            )
            let span = MKCoordinateSpan(
                latitudeDelta: max(abs(maxLat - minLat) * 1.5, 0.025),
                longitudeDelta: max(abs(maxLng - minLng) * 1.5, 0.025)
            )
            let reg = MKCoordinateRegion(center: center, span: span)
            if animated {
                withAnimation(.easeInOut(duration: 0.6)) {
                    position = .region(reg)
                }
            } else {
                position = .region(reg)
            }
        }
    }
    
    private func openInAppleMaps(target: LocationPoint) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: target.coordinate))
        mapItem.name = target.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func participantColor(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "teal": return .teal
        default: return .indigo
        }
    }
    
    // MARK: - In-View Floating Bottom Drawer (Stays ABOVE the system menu bar!)
    
    @ViewBuilder
    private func inViewBottomDrawer(for currentMeeting: Meeting) -> some View {
        VStack(spacing: 0) {
            // Drag handle & toggle header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isBottomDrawerExpanded.toggle()
                }
            } label: {
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 40, height: 4.5)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentMeeting.title)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Text("\(currentMeeting.targetLocation.title) • \(currentMeeting.acceptedParticipants.count) en route")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                            openInAppleMaps(target: currentMeeting.targetLocation)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Apple Maps")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.12))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Image(systemName: isBottomDrawerExpanded ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isBottomDrawerExpanded {
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Sleek, Decluttered Status Chips Strip
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("\(currentMeeting.acceptedParticipants.count) En Route")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
                    
                    if currentMeeting.pendingParticipants.count > 0 {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                            Text("\(currentMeeting.pendingParticipants.count) Pending")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    if currentMeeting.rejectedParticipants.count > 0 {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.red.opacity(0.8))
                                .frame(width: 6, height: 6)
                            Text("\(currentMeeting.rejectedParticipants.count) Declined")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 4)
                
                // Streamlined Friends List
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(currentMeeting.participants) { participant in
                            ParticipantRowView(
                                participant: participant,
                                targetLocation: currentMeeting.targetLocation,
                                shareURL: currentMeeting.shareURL,
                                shareMessage: meetingStore.resendInvitation(to: participant, in: currentMeeting),
                                isSelected: routeService.activeParticipantID == participant.id
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if participant.status == .accepted {
                                    selectedParticipantID = participant.id
                                    routeService.activeParticipantID = participant.id
                                    if let r = routeService.route(for: participant.id) {
                                        focusOnRoute(r)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 6)
                }
                .frame(maxHeight: 230)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}

// MARK: - Turn-by-Turn Navigation Guidance Card
struct TurnByTurnGuidanceCard: View {
    let route: LiveRoute
    let isSimulating: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Maneuver Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(route.isArrived ? Color.green : Color.blue)
                    .frame(width: 48, height: 48)
                    .shadow(color: (route.isArrived ? Color.green : Color.blue).opacity(0.4), radius: 6, y: 3)
                
                Image(systemName: route.currentManeuver?.symbolName ?? "arrow.turn.up.right")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Instruction & Live Metrics
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(route.isArrived ? "Arrived at Destination" : (route.currentManeuver?.instruction ?? "Navigating"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isSimulating {
                        Text("LIVE")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(route.progress)), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.vertical, 2)
                
                // Route Distance & ETA Summary
                HStack(spacing: 8) {
                    Text(route.formattedRemainingDistance)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    Text("•")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(route.formattedRemainingETA)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("•")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Arrival \(route.destinationETAString)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
    }
}

// MARK: - Participant Map Marker View with Live Road Distance Badge
struct ParticipantMapMarkerView: View {
    let participant: Participant
    let route: LiveRoute?
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            // Avatar Bubble
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.85), color.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: isSelected ? 44 : 38, height: isSelected ? 44 : 38)
                    .shadow(color: color.opacity(0.5), radius: isSelected ? 8 : 4, y: 2)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: isSelected ? 44 : 38, height: isSelected ? 44 : 38)
                
                Image(systemName: "car.fill")
                    .foregroundColor(.white)
                    .font(isSelected ? .body.bold() : .caption.bold())
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
            }
            
            // Live Road Driving Distance Tag
            HStack(spacing: 3) {
                if let r = route {
                    if r.isArrived {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                        Text("Arrived")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "road.lanes")
                            .font(.system(size: 7))
                            .foregroundColor(isSelected ? .white : .black.opacity(0.7))
                        Text("\(r.formattedRemainingDistance) • \(r.formattedRemainingETA)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isSelected ? .white : .black)
                    }
                } else {
                    Text(participant.name)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(isSelected ? .white : .black)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2.5)
            .background(route?.isArrived == true ? Color.green : (isSelected ? Color.blue : Color.white.opacity(0.95)))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
        }
    }
}

// MARK: - Destination Annotation View
struct DestinationAnnotationView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Pulsing outer halo
                Circle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: 52, height: 52)
                
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                    .shadow(color: .red.opacity(0.5), radius: 6, y: 3)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "flag.checkered")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.75))
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
}

struct MultiMapStatBox: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
