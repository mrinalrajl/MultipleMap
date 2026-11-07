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
    var isSelected: Bool = false
    
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
            // Avatar with status ring & indicator dot
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [avatarColor.opacity(0.85), avatarColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.cyan : avatarColor.opacity(0.4), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color.cyan.opacity(0.4) : Color.clear, radius: 4)
                
                Text(String(participant.name.prefix(1)).uppercased())
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(statusColor(participant.status))
                    .frame(width: 9, height: 9)
                    .overlay(Circle().stroke(Color(red: 0.12, green: 0.14, blue: 0.18), lineWidth: 1.5))
                    .offset(x: 1, y: 1)
            }
            
            // Name & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(participant.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if isSelected {
                        Text("TRACKING")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.25))
                            .foregroundColor(.cyan)
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 4) {
                    if participant.status == .accepted {
                        Image(systemName: "mappin.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.cyan.opacity(0.8))
                        Text(participant.originLocationName)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else if participant.status == .pending {
                        Text("Awaiting response • \(participant.originLocationName)")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.orange.opacity(0.85))
                            .lineLimit(1)
                    } else {
                        Text("Unable to attend")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.red.opacity(0.8))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Trailing Metrics or Actions
            if participant.status == .accepted {
                VStack(alignment: .trailing, spacing: 1) {
                    Text(participant.formattedDistance(to: targetLocation))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 9))
                        Text(participant.estimatedETA(to: targetLocation))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.75))
                }
            } else if participant.status == .pending, let shareURL = shareURL, let shareMessage = shareMessage {
                ShareLink(item: shareURL, subject: Text("Meeting Invitation"), message: Text(shareMessage)) {
                    HStack(spacing: 4) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 9))
                        Text("Remind")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.18))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.orange.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else if participant.status == .rejected {
                Text("Declined")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.red.opacity(0.75))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.white.opacity(0.08) : Color.clear)
        )
    }
    
    private func statusColor(_ status: ParticipantStatus) -> Color {
        switch status {
        case .accepted: return .green
        case .pending: return .orange
        case .rejected: return .red
        }
    }
}
