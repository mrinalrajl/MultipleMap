//
//  CarPlaySimulatorView.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import SwiftUI
import MapKit

#if canImport(UIKit)
import UIKit
#endif

struct CarPlaySimulatorView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCarPlayTab: CarPlayTab = .map
    
    enum CarPlayTab {
        case map
        case participants
    }
    
    var meeting: Meeting? {
        meetingStore.selectedMeeting
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // CarPlay Header Banner
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple CarPlay Display")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(meeting?.title ?? "Joint Meeting")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Spacer()
                    
                    // CarPlay Status Indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Connected")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(6)
                }
                .padding()
                #if canImport(UIKit)
                .background(Color(UIColor.secondarySystemBackground))
                #else
                .background(Color.gray.opacity(0.2))
                #endif
                
                if let currentMeeting = meeting {
                    // CarPlay Automotive Display Container
                    ZStack(alignment: .leading) {
                        // Main Display Content
                        Group {
                            if selectedCarPlayTab == .map {
                                carPlayMapView(meeting: currentMeeting)
                            } else {
                                carPlayParticipantsListView(meeting: currentMeeting)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom CarPlay Sidebar Controls
                    HStack(spacing: 20) {
                        Button {
                            selectedCarPlayTab = .map
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "map.fill")
                                    .font(.title3)
                                Text("Drive Map")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedCarPlayTab == .map ? Color.blue : Color.clear)
                            .foregroundColor(selectedCarPlayTab == .map ? .white : .primary)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            selectedCarPlayTab = .participants
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.title3)
                                Text("Attendees & ETA")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedCarPlayTab == .participants ? Color.blue : Color.clear)
                            .foregroundColor(selectedCarPlayTab == .participants ? .white : .primary)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            meetingStore.toggleLiveSimulation()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: meetingStore.isSimulatingLiveMovement ? "car.side.fill" : "play.fill")
                                    .font(.title3)
                                Text(meetingStore.isSimulatingLiveMovement ? "Moving..." : "Simulate")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(meetingStore.isSimulatingLiveMovement ? Color.green : Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    #if canImport(UIKit)
                    .background(Color(UIColor.systemBackground))
                    #else
                    .background(Color.white)
                    #endif
                    .shadow(radius: 4)
                } else {
                    ContentUnavailableView("No Active Meeting", systemImage: "car.circle", description: Text("Select a meeting to view in CarPlay mode."))
                }
            }
            .navigationTitle("CarPlay Drive View")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    // CarPlay Map View Screen
    @ViewBuilder
    private func carPlayMapView(meeting: Meeting) -> some View {
        Map(position: $position) {
            // Target Spot
            Annotation(meeting.targetLocation.title, coordinate: meeting.targetLocation.coordinate) {
                ZStack {
                    Circle().fill(Color.red).frame(width: 40, height: 40)
                    Image(systemName: "flag.fill").foregroundColor(.white)
                }
            }
            
            // Accepted Users Pins with Name and Distance
            ForEach(meeting.acceptedParticipants) { participant in
                if let loc = participant.currentLocation {
                    Annotation(participant.name, coordinate: loc.coordinate) {
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(Color.blue).frame(width: 32, height: 32)
                                Image(systemName: "car.fill").foregroundColor(.white).font(.caption)
                            }
                            Text(participant.name + " - " + loc.formattedDistance(to: meeting.targetLocation))
                                .font(.system(size: 10, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(4)
                                .background(Color.black.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .topLeading) {
            // CarPlay Driving Guidance Banner
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "arrow.turn.up.right.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("Driving to \(meeting.targetLocation.title)")
                            .font(.headline)
                        Text("\(meeting.acceptedParticipants.count) friends en route • Real-time distance updating")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding()
        }
        .onAppear {
            updateCarPlayMapCamera(meeting: meeting)
        }
    }
    
    private func updateCarPlayMapCamera(meeting: Meeting) {
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
            latitudeDelta: max(abs(maxLat - minLat) * 1.5, 0.05),
            longitudeDelta: max(abs(maxLng - minLng) * 1.5, 0.05)
        )
        position = .region(MKCoordinateRegion(center: center, span: span))
    }
    
    // CarPlay Participants & Quick Action List Screen
    @ViewBuilder
    private func carPlayParticipantsListView(meeting: Meeting) -> some View {
        List {
            Section(header: Text("Accepted Friends En Route")) {
                if meeting.acceptedParticipants.isEmpty {
                    Text("No friends have accepted yet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(meeting.acceptedParticipants) { p in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.name)
                                    .font(.headline)
                                Text("From: \(p.originLocationName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(p.formattedDistance(to: meeting.targetLocation))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("ETA: \(p.estimatedETA(to: meeting.targetLocation))")
                                    .font(.caption)
                                    .foregroundColor(.indigo)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Pending Friends (Tap to Resend Invite)")) {
                if meeting.pendingParticipants.isEmpty {
                    Text("All invites accepted or replied!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(meeting.pendingParticipants) { p in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(p.name)
                                    .font(.headline)
                                Text("Invite status: Pending")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            ShareLink(item: meeting.shareURL, subject: Text("Meeting Invitation"), message: Text(meetingStore.resendInvitation(to: p, in: meeting))) {
                                HStack(spacing: 4) {
                                    Image(systemName: "paperplane.fill")
                                    Text("Invite")
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
        }
    }
}
