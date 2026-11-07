import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedMeetingForDetail: Meeting?
    
    let filterOptions = ["All", "Accepted", "Pending", "Hosted"]
    
    var filteredMeetings: [Meeting] {
        meetingStore.meetings.filter { meeting in
            let matchesSearch = searchText.isEmpty ||
                meeting.title.localizedCaseInsensitiveContains(searchText) ||
                meeting.targetLocation.title.localizedCaseInsensitiveContains(searchText) ||
                meeting.hostName.localizedCaseInsensitiveContains(searchText)
            
            if !matchesSearch { return false }
            
            switch selectedFilter {
            case "Accepted":
                return !meeting.acceptedParticipants.isEmpty
            case "Pending":
                return !meeting.pendingParticipants.isEmpty
            case "Hosted":
                return meeting.hostName.contains("Alex") || meeting.hostName.contains("Host")
            default:
                return true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segment Control
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Overview Stats Card
                        if !meetingStore.meetings.isEmpty {
                            HStack(spacing: 12) {
                                HistoryStatBox(title: "Total Syncs", value: "\(meetingStore.meetings.count)", icon: "calendar", color: .blue)
                                HistoryStatBox(title: "Accepted", value: "\(meetingStore.meetings.reduce(0) { $0 + $1.acceptedParticipants.count })", icon: "checkmark.circle.fill", color: .green)
                                HistoryStatBox(title: "Locations", value: "\(Set(meetingStore.meetings.map { $0.targetLocation.title }).count)", icon: "mappin.and.ellipse", color: .orange)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Meeting List
                        if filteredMeetings.isEmpty {
                            ContentUnavailableView(
                                searchText.isEmpty ? "No History" : "No Matches",
                                systemImage: searchText.isEmpty ? "clock.badge.xmark" : "magnifyingglass",
                                description: Text(searchText.isEmpty ? "Your past joint meetings will appear here." : "Try searching for another location or title.")
                            )
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredMeetings) { meeting in
                                    HistoryCardView(meeting: meeting) {
                                        selectedMeetingForDetail = meeting
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    .padding(.bottom, 20)
                }
            }
            .searchable(text: $searchText, prompt: "Search meetings, locations, hosts...")
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("History")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(item: $selectedMeetingForDetail) { meeting in
                HistoryMeetingDetailSheet(meeting: meeting)
            }
        }
    }
}

struct HistoryStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct HistoryCardView: View {
    let meeting: Meeting
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: locationIcon(for: meeting.targetLocation.title))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(meeting.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text(meeting.targetLocation.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(meeting.scheduledDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundColor(.cyan)
                            Text(meeting.hostName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private func locationIcon(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("coffee") || lower.contains("cafe") || lower.contains("starbucks") {
            return "cup.and.saucer.fill"
        } else if lower.contains("airport") || lower.contains("flight") {
            return "airplane"
        } else if lower.contains("park") || lower.contains("nature") {
            return "leaf.fill"
        } else if lower.contains("restaurant") || lower.contains("food") {
            return "fork.knife"
        } else if lower.contains("gym") || lower.contains("workout") {
            return "dumbbell.fill"
        } else if lower.contains("mall") || lower.contains("plaza") || lower.contains("store") {
            return "cart.fill"
        }
        return "mappin.and.ellipse"
    }
}

struct HistoryMeetingDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var meetingStore: MeetingStore
    @Environment(AppRouter.self) private var appRouter
    let meeting: Meeting
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meeting.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(meeting.targetLocation.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let subtitle = meeting.targetLocation.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text(meeting.scheduledDate, style: .date)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.badge.key.fill")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                Text("Host: \(meeting.hostName)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Meeting Note
                    if !meeting.note.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Meeting Note")
                                .font(.headline)
                            Text(meeting.note)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Participants Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Participants (\(meeting.participants.count))")
                            .font(.headline)
                        
                        ForEach(meeting.participants) { p in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(statusColor(p.status).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(p.name.prefix(1)))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(statusColor(p.status))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(p.originLocationName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(p.status.rawValue.capitalized)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(statusColor(p.status).opacity(0.15))
                                    .foregroundColor(statusColor(p.status))
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            meetingStore.selectedMeetingID = meeting.id
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                appRouter.selectedTab = 0
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("View on Multi-Map")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        ShareLink(item: meeting.shareURL, subject: Text(meeting.title), message: Text("Join us at \(meeting.title)!")) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Meeting Link")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(14)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meeting Details")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func statusColor(_ status: ParticipantStatus) -> Color {
        switch status {
        case .accepted: return .green
        case .pending: return .orange
        case .rejected: return .red
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(MeetingStore())
    }
}
