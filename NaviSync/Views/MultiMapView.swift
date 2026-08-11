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
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedParticipantID: Participant.ID?
    @State private var isSheetHidden = false
    @State private var isSheetPresented = true
    
    #if os(iOS)
    @State private var selectedDetent: UISheetPresentationController.Detent.Identifier? = .medium
    #endif

    
    var meeting: Meeting? {
        meetingStore.selectedMeeting
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if let currentMeeting = meeting {
                    // Modern iOS 17 Map View
                    Map(position: $position, selection: $selectedParticipantID) {
                        // 1. Target Meeting Spot Pin
                        Annotation(currentMeeting.targetLocation.title, coordinate: currentMeeting.targetLocation.coordinate) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.red.opacity(0.8), .red.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .red.opacity(0.4), radius: 6, x: 0, y: 3)
                                
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                        }
                        .annotationTitles(.visible)
                        
                        // 2. Accepted Participants Pins
                        ForEach(currentMeeting.acceptedParticipants) { participant in
                            if let loc = participant.currentLocation {
                                Annotation(participant.name, coordinate: loc.coordinate) {
                                    VStack(spacing: 2) {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(gradient: Gradient(colors: [participantColor(participant.avatarColorName).opacity(0.8), participantColor(participant.avatarColorName).opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .frame(width: 38, height: 38)
                                                .shadow(color: participantColor(participant.avatarColorName).opacity(0.4), radius: 4, x: 0, y: 2)
                                            
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .frame(width: 38, height: 38)
                                            
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.body)
                                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                                        }
                                        
                                        // Distance Tag
                                        Text(loc.formattedDistance(to: currentMeeting.targetLocation))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.9))
                                            .foregroundColor(.black)
                                            .cornerRadius(6)
                                            .shadow(radius: 2)
                                    }
                                }
                                .tag(participant.id)
                            }
                        }
                        
                        // 3. Polylines from Accepted Participants to Target
                        ForEach(currentMeeting.acceptedParticipants) { participant in
                            if let loc = participant.currentLocation {
                                MapPolyline(coordinates: [loc.coordinate, currentMeeting.targetLocation.coordinate])
                                    .stroke(participantColor(participant.avatarColorName).opacity(0.6), lineWidth: 3)
                            }
                        }
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapPitchToggle()
                    }
                    .onTapGesture {
                        withAnimation {
                            isSheetHidden.toggle()
                        }
                    }
                    .onChange(of: selectedParticipantID) { oldId, newId in
                        if newId != nil {
                            isSheetHidden = false
                            #if os(iOS)
                            selectedDetent = .medium
                            #endif
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        // Top Map Floating Action Controls
                        VStack(spacing: 8) {
                            Button {
                                updateMapCameraToFitAll()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .padding(10)
                                    .background(.thinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            
                            Button {
                                meetingStore.toggleLiveSimulation()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: meetingStore.isSimulatingLiveMovement ? "car.side.fill" : "play.fill")
                                    Text(meetingStore.isSimulatingLiveMovement ? "Simulating..." : "Simulate Live")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(meetingStore.isSimulatingLiveMovement ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                            }
                        }
                        .padding()
                    }
                    .environment(\.colorScheme, .dark)
                    
                } else {
                    ContentUnavailableView("No Meeting Selected", systemImage: "map.fill", description: Text("Create or select a joint meeting to view multi-map tracking."))
                }
                
                
            }
            .sheet(isPresented: $isSheetPresented) {
                if let currentMeeting = meeting {
                    multiMapSheet(for: currentMeeting)
                        #if os(iOS)
                        .mapSheetPresentation(isHidden: $isSheetHidden, selectedDetent: $selectedDetent)
                        .presentationDetents([.fraction(0.15), .medium, .large])
                        .presentationBackgroundInteraction(.enabled)
                        .presentationCornerRadius(20)
                        .presentationBackground(.ultraThinMaterial)
                        #endif
                }
            }
            .navigationTitle("Multi-Map Live")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(meetingStore.meetings) { m in
                            Button {
                                meetingStore.selectedMeetingID = m.id
                                updateMapCameraToFitAll()
                            } label: {
                                Label(m.title, systemImage: m.id == meetingStore.selectedMeetingID ? "checkmark" : "map")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                updateMapCameraToFitAll()
            }
        }
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
        let span = MKCoordinateSpan(
            latitudeDelta: max(abs(maxLat - minLat) * 1.5, 0.05),
            longitudeDelta: max(abs(maxLng - minLng) * 1.5, 0.05)
        )
        position = .region(MKCoordinateRegion(center: center, span: span))
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
    
    // MARK: - Native Bottom Sheet Content
    
    @ViewBuilder
    private func multiMapSheet(for currentMeeting: Meeting) -> some View {
        VStack(spacing: 0) {
            // Title row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentMeeting.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(currentMeeting.targetLocation.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    openInAppleMaps(target: currentMeeting.targetLocation)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 8)
            
            Divider()
            
            // Stats row
            HStack {
                MultiMapStatBox(title: "Accepted", count: currentMeeting.acceptedParticipants.count, color: .green)
                MultiMapStatBox(title: "Pending", count: currentMeeting.pendingParticipants.count, color: .orange)
                MultiMapStatBox(title: "Declined", count: currentMeeting.rejectedParticipants.count, color: .red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            // Participants list (scrollable when expanded)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(currentMeeting.participants) { participant in
                        ParticipantRowView(
                            participant: participant,
                            targetLocation: currentMeeting.targetLocation,
                            shareURL: currentMeeting.shareURL,
                            shareMessage: meetingStore.resendInvitation(to: participant, in: currentMeeting)
                        )
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .environment(\.colorScheme, .dark)
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
