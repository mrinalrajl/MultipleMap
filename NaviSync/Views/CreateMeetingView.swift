//
//  CreateMeetingView.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import SwiftUI
import MapKit

#if canImport(UIKit)
import UIKit
#endif

struct CreateMeetingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var meetingStore: MeetingStore
    
    @State private var title: String = "Joint Coffee & Catchup"
    @State private var note: String = "Hey friends! Let's meet up at this spot."
    @State private var scheduledDate: Date = Date().addingTimeInterval(3600)
    
    // Host Info (Person X)
    @State private var hostName: String = "Alex Rivera (Person X)"
    @State private var hostContact: String = "+1 (704) 555-0100"
    @State private var hostOrigin: String = "Uptown Charlotte"
    
    // Target Location Selection
    @State private var placeTitle: String = "Starbucks Coffee Hub"
    @State private var placeSubtitle: String = "100 N Tryon St, Charlotte, NC"
    @State private var latitudeStr: String = "35.2271"
    @State private var longitudeStr: String = "-80.8431"
    
    // Invitees to add
    @State private var newInviteeName: String = ""
    @State private var inviteesList: [String] = ["Sarah Jenkins", "Marcus Vance", "David Kim"]
    
    @State private var createdMeeting: Meeting?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Meeting Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Meeting Details")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            TextField("Meeting Title", text: $title)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            TextField("Note / Description", text: $note)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            DatePicker("Scheduled Time", selection: $scheduledDate, in: Date()...)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Target Location
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Target Destination")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            TextField("Spot Name (e.g. Starbucks Plaza)", text: $placeTitle)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            TextField("Address / Subtitle", text: $placeSubtitle)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            // Quick Location Presets
                            Menu {
                                Button("Charlotte Uptown Center") {
                                    placeTitle = "Uptown City Center"
                                    placeSubtitle = "Charlotte, NC"
                                    latitudeStr = "35.2271"
                                    longitudeStr = "-80.8431"
                                }
                                Button("South End Cafe & Mall") {
                                    placeTitle = "South End Cafe"
                                    placeSubtitle = "South Blvd, Charlotte, NC"
                                    latitudeStr = "35.2120"
                                    longitudeStr = "-80.8580"
                                }
                                Button("NoDa Plaza") {
                                    placeTitle = "NoDa Arts Meeting Hub"
                                    placeSubtitle = "N Davidson St, Charlotte, NC"
                                    latitudeStr = "35.2450"
                                    longitudeStr = "-80.8100"
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Choose from Quick Presets")
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Host Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Information (Host)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            TextField("Your Name", text: $hostName)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            TextField("Your Phone / Contact", text: $hostContact)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add Friends
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Invite Friends")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Friend's Name", text: $newInviteeName)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            
                            Button {
                                guard !newInviteeName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                inviteesList.append(newInviteeName.trimmingCharacters(in: .whitespaces))
                                newInviteeName = ""
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        
                        if !inviteesList.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(inviteesList, id: \.self) { name in
                                        HStack(spacing: 6) {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundColor(.blue)
                                            Text(name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Button {
                                                if let idx = inviteesList.firstIndex(of: name) {
                                                    inviteesList.remove(at: idx)
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color(UIColor.tertiarySystemFill))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("New Joint Meeting")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create & Share") {
                        saveMeetingAndShare()
                    }
                    .fontWeight(.bold)
                }
            }
            .overlay {
                if let m = createdMeeting {
                    // Post-creation confirmation with share action
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.green)
                            Text("Meeting Created!")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(m.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ShareLink(item: m.shareURL, subject: Text(m.title), message: Text("Join us at \(m.title)! Open this link to RSVP.")) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Invite Link")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(32)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: createdMeeting != nil)
        }
    }
    
    private func saveMeetingAndShare() {
        let lat = Double(latitudeStr.trimmingCharacters(in: .whitespaces)) ?? 35.2271
        let lng = Double(longitudeStr.trimmingCharacters(in: .whitespaces)) ?? -80.8431
        
        let targetLoc = LocationPoint(
            title: placeTitle.isEmpty ? "Joint Meeting Spot" : placeTitle,
            subtitle: placeSubtitle,
            latitude: lat,
            longitude: lng
        )
        
        let newM = meetingStore.createMeeting(
            title: title.isEmpty ? "Joint Meeting" : title,
            note: note,
            scheduledDate: scheduledDate,
            hostName: hostName.isEmpty ? "Person X" : hostName,
            hostContact: hostContact,
            hostOrigin: hostOrigin.isEmpty ? "Origin" : hostOrigin,
            targetLocation: targetLoc,
            initialInvitedNames: inviteesList
        )
        
        withAnimation {
            createdMeeting = newM
        }
    }
}
