//
//  ParticipantRowView.swift
//  NaviSync
//
//  Created for NaviSync App.
//

import SwiftUI
import CoreLocation

struct ParticipantRowView: View {
    let participant: Participant
    let targetLocation: LocationPoint
    let shareURL: URL?
    let shareMessage: String?
    
    @State private var isShowingContactAlert = false
    
    var avatarColor: Color {
        switch participant.avatarColorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "teal": return .teal
        default: return .indigo
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.2))
                    .frame(width: 46, height: 46)
                
                Text(String(participant.name.prefix(1)).uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(avatarColor)
            }
            
            // Participant Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(participant.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: participant.status.iconName)
                            .font(.caption2)
                        Text(participant.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusBackgroundColor(participant.status))
                    .foregroundColor(statusForegroundColor(participant.status))
                    .clipShape(Capsule())
                }
                
                // Origin & Contact Info
                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("From: \(participant.originLocationName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !participant.contactInfo.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(participant.contactInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Distance & ETA if Accepted
                if participant.status == .accepted, let loc = participant.currentLocation {
                    HStack(spacing: 12) {
                        Label(loc.formattedDistance(to: targetLocation), systemImage: "location.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Label("ETA: \(loc.estimatedETA(to: targetLocation))", systemImage: "car.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.indigo)
                    }
                    .padding(.top, 2)
                }
            }
            
            // Resend Invite / Ping Button for Pending Users
            if participant.status == .pending, let shareURL = shareURL, let shareMessage = shareMessage {
                ShareLink(item: shareURL, subject: Text("Meeting Invitation"), message: Text(shareMessage)) {
                    VStack(spacing: 2) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14))
                        Text("Send Link")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 6)
    }
    
    private func statusBackgroundColor(_ status: ParticipantStatus) -> Color {
        switch status {
        case .accepted: return Color.green.opacity(0.15)
        case .pending: return Color.orange.opacity(0.15)
        case .rejected: return Color.red.opacity(0.15)
        }
    }
    
    private func statusForegroundColor(_ status: ParticipantStatus) -> Color {
        switch status {
        case .accepted: return .green
        case .pending: return .orange
        case .rejected: return .red
        }
    }
}
