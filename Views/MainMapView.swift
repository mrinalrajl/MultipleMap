import SwiftUI
import MapKit

struct MainMapView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationService = LocationService()
    
    @State private var showContactsSheet = true
    @State private var showPrivacyBanner = true
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    
    // Nudge toast state
    @State private var showNudgeToast = false
    @State private var nudgedFriendName = ""
    
    // Timer for mock real-time movement
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background Map
            Map(position: $mapCameraPosition) {
                // Current User
                if let userLoc = locationService.location ?? viewModel.currentUser.location {
                    Annotation("Me", coordinate: userLoc) {
                        ZStack {
                            Circle().fill(Color.blue).frame(width: 28, height: 28)
                            if let imageName = viewModel.currentUser.imageName {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            } else {
                                Text("Me").font(.caption).bold().foregroundColor(.white)
                            }
                            Circle().stroke(Color.white, lineWidth: 3).frame(width: 28, height: 28)
                        }
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: userLoc.latitude)
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: userLoc.longitude)
                    }
                }
                
                // Meeting Location with Custom Icon
                if let meeting = viewModel.meetingLocation {
                    Annotation(meeting.title, coordinate: meeting.coordinate) {
                        Text(meeting.icon ?? "📍")
                            .font(.system(size: 36))
                            .shadow(radius: 5)
                            .animation(.bouncy, value: meeting.icon)
                    }
                }
                
                // Friends
                ForEach(viewModel.friends) { friend in
                    if let loc = friend.location {
                        Annotation(friend.name, coordinate: loc) {
                            ZStack {
                                Circle().fill(Color.green).frame(width: 28, height: 28)
                                if let imageName = friend.imageName {
                                    Image(systemName: imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                } else {
                                    Text(String(friend.name.prefix(1))).font(.caption).bold().foregroundColor(.white)
                                }
                                Circle().stroke(Color.white, lineWidth: 2).frame(width: 28, height: 28)
                            }
                            .animation(.spring(), value: loc.latitude)
                            .animation(.spring(), value: loc.longitude)
                        }
                    }
                }
                
                // Route
                if let route = viewModel.routeToMeeting {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            // iPad/Mac Floating Sidebar Overlay
            if horizontalSizeClass == .regular {
                HStack {
                    ContactBottomSheetView(viewModel: viewModel, onNudge: { friend in
                        triggerNudge(friend: friend)
                    })
                    .frame(width: 350)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding()
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
            
            // UI Overlays
            VStack {
                // Top Overlay: Privacy Banner
                PrivacyBannerView(isPresented: $showPrivacyBanner)
                    .padding(.top, 8)
                
                // Active sharing indicator if banner is hidden
                if !showPrivacyBanner, let endTime = viewModel.meetingLocation?.sharingEndTime {
                    HStack {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("Sharing Active")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                    }
                    .padding(8)
                    .background(Capsule().fill(Color(UIColor.secondarySystemBackground)))
                    .shadow(radius: 2)
                    .padding(.top, 8)
                    .transition(.opacity)
                }
                
                // Nudge Toast
                if showNudgeToast {
                    HStack {
                        Text("👉")
                        Text("Nudged \(nudgedFriendName)!")
                            .font(.headline)
                    }
                    .padding()
                    .background(Capsule().fill(Color.white))
                    .shadow(radius: 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Share Button
                HStack {
                    Spacer()
                    Button(action: {
                        if let link = viewModel.meetingLocation?.inviteLink {
                            let av = UIActivityViewController(activityItems: [link], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let root = windowScene.windows.first?.rootViewController {
                                root.present(av, animated: true, completion: nil)
                            }
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                Spacer().frame(height: horizontalSizeClass == .compact ? 100 : 20) // Adjust space for compact bottom sheet
            }
        }
        .sheet(isPresented: Binding(
            get: { showContactsSheet && horizontalSizeClass == .compact },
            set: { showContactsSheet = $0 }
        )) {
            ContactBottomSheetView(viewModel: viewModel, onNudge: { friend in
                triggerNudge(friend: friend)
            })
                .presentationDetents([.fraction(0.15), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .interactiveDismissDisabled()
        }
        .onAppear {
            locationService.requestPermission()
            if viewModel.meetingLocation == nil {
                viewModel.meetingLocation = MeetingLocation.mockMeeting
                Task { await viewModel.calculateRoute() }
            }
            if let route = viewModel.routeToMeeting {
                mapCameraPosition = .rect(route.polyline.boundingMapRect)
            }
        }
        .onChange(of: viewModel.selectedFriend) { _, newFriend in
            if let newFriend = newFriend, let loc = newFriend.location {
                withAnimation {
                    mapCameraPosition = .camera(MapCamera(centerCoordinate: loc, distance: 5000))
                }
            }
        }
        .onReceive(timer) { _ in
            // Mock smooth movement towards meeting location
            guard let dest = viewModel.meetingLocation?.coordinate else { return }
            for i in 0..<viewModel.friends.count {
                if let loc = viewModel.friends[i].location {
                    // Move 10% closer to the destination every tick
                    let newLat = loc.latitude + (dest.latitude - loc.latitude) * 0.1
                    let newLon = loc.longitude + (dest.longitude - loc.longitude) * 0.1
                    
                    withAnimation(.spring(response: 2.0, dampingFraction: 0.8)) {
                        viewModel.friends[i].location = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
                    }
                }
            }
            
            // Move current user as well if using mock location
            if locationService.location == nil, let userLoc = viewModel.currentUser.location {
                let newLat = userLoc.latitude + (dest.latitude - userLoc.latitude) * 0.1
                let newLon = userLoc.longitude + (dest.longitude - userLoc.longitude) * 0.1
                
                withAnimation(.spring(response: 2.0, dampingFraction: 0.8)) {
                    viewModel.currentUser.location = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
                }
            }
        }
    }
    
    private func triggerNudge(friend: User) {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        nudgedFriendName = friend.name
        withAnimation { showNudgeToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showNudgeToast = false }
        }
    }
}

#Preview {
    MainMapView()
}
