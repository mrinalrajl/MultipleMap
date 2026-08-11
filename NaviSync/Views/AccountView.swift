import SwiftUI

struct GlassIcon: View {
    var iconName: String
    var color: Color
    var size: CGFloat = 32
    var iconSize: CGFloat = 16
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.7), color.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.3), radius: size / 4, x: 0, y: size / 8)
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
            
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
    }
}

struct AccountView: View {
    @EnvironmentObject var meetingStore: MeetingStore
    
    @State private var userName = "Alex Rivera"
    @State private var userPhone = "+1 (704) 555-0100"
    @State private var userEmail = "alex.rivera@example.com"
    
    @State private var notificationsEnabled = true
    @State private var autoStartLiveActivity = true
    @State private var shareLocationInMeetings = true
    @State private var shareLocationIndefinitely = false
    @State private var defaultTravelMode = "Driving"
    @State private var distanceUnits = "Miles (mi)"
    @State private var mapStyle = "Standard"
    @State private var useFaceID = true
    
    @State private var isShowingEditProfile = false
    @State private var isShowingPrivacyPolicy = false
    @State private var isShowingClearCacheAlert = false
    @State private var isShowingSignOutAlert = false
    
    let travelModes = ["Driving", "Transit", "Walking", "Bicycling"]
    let unitOptions = ["Miles (mi)", "Kilometers (km)"]
    let mapStyles = ["Standard", "Satellite", "Hybrid"]
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Card
                Section {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            GlassIcon(iconName: "person.fill", color: .blue, size: 64, iconSize: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(userName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                                
                                Text(userPhone)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(userEmail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                isShowingEditProfile = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Divider()
                        
                        // User Stats Summary
                        HStack {
                            VStack(spacing: 2) {
                                Text("\(meetingStore.meetings.count)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("Meetings")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 24)
                            
                            VStack(spacing: 2) {
                                Text(defaultTravelMode)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Travel Mode")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 24)
                            
                            VStack(spacing: 2) {
                                Text("Active")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Live Activity")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                }
                
                // MARK: - Navigation Preferences
                Section(header: Text("Navigation & Map Preferences")) {
                    HStack {
                        GlassIcon(iconName: "car.fill", color: .orange)
                        Picker("Default Travel Mode", selection: $defaultTravelMode) {
                            ForEach(travelModes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    HStack {
                        GlassIcon(iconName: "ruler.fill", color: .cyan)
                        Picker("Distance Units", selection: $distanceUnits) {
                            ForEach(unitOptions, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    HStack {
                        GlassIcon(iconName: "map.fill", color: .indigo)
                        Picker("Map Style", selection: $mapStyle) {
                            ForEach(mapStyles, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    HStack {
                        GlassIcon(iconName: "bell.fill", color: .red)
                        Toggle("Push Notifications", isOn: $notificationsEnabled)
                            .tint(.blue)
                    }
                    
                    HStack {
                        GlassIcon(iconName: "bolt.horizontal.circle.fill", color: .purple)
                        Toggle("Auto-Start Live Activity", isOn: $autoStartLiveActivity)
                            .tint(.blue)
                    }
                }
                
                // MARK: - Privacy & Security
                Section(
                    header: Text("Privacy & Security"),
                    footer: Text("When enabled, NaviSync only shares your real-time coordinates during active accepted meeting events.")
                ) {
                    HStack {
                        GlassIcon(iconName: "location.fill", color: .green)
                        Toggle("Share Location During Meetings", isOn: $shareLocationInMeetings)
                            .tint(.green)
                    }
                    
                    HStack {
                        GlassIcon(iconName: "clock.fill", color: .teal)
                        Toggle("Keep Sharing After Arrival", isOn: $shareLocationIndefinitely)
                            .tint(.green)
                    }
                    
                    HStack {
                        GlassIcon(iconName: "faceid", color: .blue)
                        Toggle("Require Face ID to Open", isOn: $useFaceID)
                            .tint(.blue)
                    }
                    
                    HStack {
                        GlassIcon(iconName: "checkmark.shield.fill", color: .mint)
                        Text("Location Access")
                        Spacer()
                        Text("Always Allowed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }
                
                // MARK: - App Info & Storage
                Section(header: Text("App & Resources")) {
                    NavigationLink(destination: AppClipGuideView()) {
                        HStack {
                            GlassIcon(iconName: "app.clip", color: .blue)
                            Text("Applet & System Policies")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button {
                        isShowingPrivacyPolicy = true
                    } label: {
                        HStack {
                            GlassIcon(iconName: "hand.raised.fill", color: .purple)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button {
                        isShowingClearCacheAlert = true
                    } label: {
                        HStack {
                            GlassIcon(iconName: "trash.fill", color: .pink)
                            Text("Reset Local Meeting Data")
                                .foregroundColor(.pink)
                        }
                    }
                }
                
                // MARK: - Sign Out
                Section {
                    Button {
                        isShowingSignOutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                } footer: {
                    VStack(spacing: 4) {
                        Text("NaviSync v1.2 (Build 2026.8.8)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Joint Meeting & Live Location Sync")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Account")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileSheet(userName: $userName, userPhone: $userPhone, userEmail: $userEmail)
            }
            .sheet(isPresented: $isShowingPrivacyPolicy) {
                PrivacyPolicySheet()
            }
            .alert("Reset Saved Data?", isPresented: $isShowingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "NaviSync_Saved_Meetings_v1")
                }
            } message: {
                Text("This will restore default meeting sample data and clear local cache.")
            }
            .alert("Sign Out?", isPresented: $isShowingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) { }
            } message: {
                Text("You will need to re-authenticate to sync your live meetings.")
            }
        }
    }
}

struct EditProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @Binding var userPhone: String
    @Binding var userEmail: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Full Name", text: $userName)
                    TextField("Phone Number", text: $userPhone)
                        #if !os(macOS)
                        .keyboardType(.phonePad)
                        #endif
                    TextField("Email Address", text: $userEmail)
                        #if !os(macOS)
                        .keyboardType(.emailAddress)
                        #endif
                }
            }
            .navigationTitle("Edit Profile")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("NaviSync Privacy Policy")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Last updated: August 8, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("1. Real-Time Location Privacy")
                        .font(.headline)
                    Text("NaviSync collects your location data only when you are actively participating in an accepted joint meeting. Location streaming stops automatically upon arrival or when you end the trip.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("2. Participant Data Sharing")
                        .font(.headline)
                    Text("Your live coordinates, estimated time of arrival (ETA), and travel speed are shared exclusively with confirmed participants of the specific meeting you joined.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("3. Data Security")
                        .font(.headline)
                    Text("All location transmission occurs over encrypted HTTPS connections using end-to-end authentication protocols.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
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
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(MeetingStore())
    }
}
