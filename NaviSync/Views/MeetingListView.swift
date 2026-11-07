//
//  MeetingListView.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct MeetingListView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    
    @State private var isShowingCreateSheet = false
    @State private var newPendingName = ""
    @State private var activeMeetingForPendingAdd: Meeting?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if meetingStore.meetings.isEmpty {
                        ContentUnavailableView("No Meetings", systemImage: "calendar.badge.plus", description: Text("Create a joint meeting to get started."))
                            .padding(.top, 40)
                    } else {
                        ForEach(meetingStore.meetings) { meeting in
                            MeetingCardView(meeting: meeting)
                        }
                    }
                    
                    // Deep Link Testing Section
                    VStack(alignment: .leading) {
                        Text("Developer Tools")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        
                        Button {
                            if let first = meetingStore.meetings.first {
                                let testURL = first.shareURL
                                _ = deepLinkManager.handleURL(testURL)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(.white)
                                Text("Simulate Invite as Friend")
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Joint Meetings")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCreateSheet = true
                    } label: {
                        Label("New Meeting", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                CreateMeetingView()
            }
        }
    }
}

struct MeetingCardView: View {
    let meeting: Meeting
    @EnvironmentObject var meetingStore: MeetingStore
    @Environment(AppRouter.self) private var appRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if meeting.id == meetingStore.selectedMeetingID {
                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Text(meeting.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                        Text(meeting.targetLocation.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ShareLink(item: meeting.shareURL, subject: Text(meeting.title), message: Text("Join us at \(meeting.title)!")) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            // Stats
            HStack {
                VStack {
                    Text("\(meeting.acceptedParticipants.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Accepted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text("\(meeting.pendingParticipants.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text("\(meeting.rejectedParticipants.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Declined")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            
            // Actions
            HStack {
                Button {
                    meetingStore.selectedMeetingID = meeting.id
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        appRouter.selectedTab = 0
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                        Text("View on Multi-Map")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(meeting.id == meetingStore.selectedMeetingID ? Color.blue : Color.blue.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // Pending invites reminder
            if !meeting.pendingParticipants.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pending Invites")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    ForEach(meeting.pendingParticipants) { p in
                        HStack {
                            Text(p.name)
                                .font(.subheadline)
                            Spacer()
                            ShareLink(item: meeting.shareURL, subject: Text(meeting.title), message: Text(meetingStore.resendInvitation(to: p, in: meeting))) {
                                Text("Remind")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
