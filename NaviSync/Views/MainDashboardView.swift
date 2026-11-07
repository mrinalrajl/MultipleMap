//
//  MainDashboardView.swift
//  NaviSync
//

import SwiftUI
import MapKit

// MARK: - Mock Data Models
struct SyncUser: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let avatarURL: URL?
    let color: Color
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // SF
            distance: 5000,
            heading: 45,
            pitch: 60
        )
    )
    
    // Mock Route Data
    let routeCoordinates = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
        CLLocationCoordinate2D(latitude: 37.7949, longitude: -122.3994)
    ]
    
    // Mock Users
    let users = [
        SyncUser(name: "Eve", coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), avatarURL: URL(string: "https://i.pravatar.cc/150?img=47"), color: .cyan),
        SyncUser(name: "Alex", coordinate: CLLocationCoordinate2D(latitude: 37.7949, longitude: -122.3994), avatarURL: URL(string: "https://i.pravatar.cc/150?img=11"), color: .green)
    ]
    
    var body: some View {
        ZStack {
            // 1. 3D Map
            Map(position: $cameraPosition) {
                // Route Polyline
                MapPolyline(coordinates: routeCoordinates)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
                // Route Polyline Glow (Thinner bright stroke over thick blue)
                MapPolyline(coordinates: routeCoordinates)
                    .stroke(Color.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                
                // Custom Annotations
                ForEach(users) { user in
                    Annotation(user.name, coordinate: user.coordinate) {
                        TeardropAnnotationView(user: user)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            // 2. Overlays
            VStack {
                // Top Navigation Card
                HStack {
                    NavigationInstructionCard()
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Bottom Timeline Widget
                LiveJourneyTimelineWidget()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Teardrop Annotation
struct TeardropAnnotationView: View {
    let user: SyncUser
    
    var body: some View {
        VStack(spacing: 0) {
            // Avatar Bubble
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                
                AsyncImage(url: user.avatarURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                Circle()
                    .stroke(user.color, lineWidth: 3)
                    .frame(width: 44, height: 44)
            }
            
            // Teardrop Pointer
            Image(systemName: "triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(user.color)
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
    }
}

// MARK: - Top Navigation Card
struct NavigationInstructionCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "arrow.turn.up.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("In 500 ft")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.7))
                Text("Turn right onto Market St")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.regularMaterial)
        .environment(\.colorScheme, .dark)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// MARK: - Live Journey Timeline Widget
struct LiveJourneyTimelineWidget: View {
    // 0.0 to 1.0 progress
    @State private var progress: CGFloat = 0.65
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Eve's Journey")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("Driving")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.3))
                    .foregroundColor(.cyan)
                    .clipShape(Capsule())
            }
            
            // Timeline Track
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let currentX = trackWidth * progress
                
                ZStack(alignment: .leading) {
                    // Dotted Track Line
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                        .foregroundColor(Color.white.opacity(0.2))
                        .frame(height: 3)
                    
                    // Filled Track Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: currentX, height: 4)
                        .cornerRadius(2)
                        .shadow(color: Color.cyan.opacity(0.6), radius: 4, x: 0, y: 0)
                    
                    // Sliding Avatar Indicator
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                        
                        AsyncImage(url: URL(string: "https://i.pravatar.cc/150?img=47")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    }
                    .position(x: currentX, y: geo.size.height / 2)
                }
            }
            .frame(height: 24)
            .padding(.vertical, 4)
            
            // ETA Footer
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time Left")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("03:4m")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arrival")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("17:06")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.25), radius: 15, y: 10)
    }
}

// Helper for the dotted line
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

#Preview {
    MainDashboardView()
}
