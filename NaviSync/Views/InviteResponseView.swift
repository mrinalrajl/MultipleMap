import SwiftUI
import MapKit

#if canImport(UIKit)
import UIKit
#endif

struct InviteResponseView: View {
    let payload: InvitePayload
    let onComplete: () -> Void
    
    @EnvironmentObject var meetingStore: MeetingStore
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var emailInput: String = ""
    @State private var participantName: String = ""
    @State private var contactInfo: String = ""
    @State private var originLocationName: String = ""
    @State private var position: MapCameraPosition = .automatic
    @State private var isAcceptedSuccess = false
    @State private var isDeclinedSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Deep space dark background
                Color(red: 0.05, green: 0.05, blue: 0.08)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            // Glass effect header icon
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 72, height: 72)
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 72, height: 72)
                                
                                Image(systemName: "envelope.open.fill")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                            
                            Text("You're Invited!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("\(payload.hostName) invited you to meet up")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Meeting Details Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text(payload.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(payload.targetLocation.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Text(payload.targetLocation.subtitle ?? "Target Location")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            // Interactive Location Map Preview with Glass Pin
                            Map(position: $position) {
                                Annotation(payload.targetLocation.title, coordinate: payload.targetLocation.coordinate) {
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
                            }
                            .frame(height: 160)
                            .cornerRadius(12)
                            .environment(\.colorScheme, .dark)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Authentication & Input Form
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Sign In or Enter Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // SSO Buttons (Apple, Google)
                            VStack(spacing: 12) {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "applelogo")
                                        Text("Continue with Apple")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "globe")
                                        Text("Continue with Google")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            HStack {
                                VStack { Divider().background(Color.white.opacity(0.2)) }
                                Text("OR")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                VStack { Divider().background(Color.white.opacity(0.2)) }
                            }
                            .padding(.vertical, 4)
                            
                            // High Contrast Inputs
                            VStack(spacing: 16) {
                                highContrastTextField(placeholder: "Email Address", text: $emailInput, icon: "envelope.fill")
                                highContrastTextField(placeholder: "Full Name", text: $participantName, icon: "person.fill")
                                highContrastTextField(placeholder: "Origin Location", text: $originLocationName, icon: "location.fill")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Accept / Reject Actions
                        VStack(spacing: 12) {
                            Button {
                                submitResponse(status: .accepted)
                            } label: {
                                HStack {
                                    Text("Accept & Share Location")
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(participantName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.white.opacity(0.5) : Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(30)
                            }
                            .disabled(participantName.trimmingCharacters(in: .whitespaces).isEmpty)
                            
                            Button {
                                submitResponse(status: .rejected)
                            } label: {
                                Text("Decline Invitation")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .navigationBarHidden(true)
            .onAppear {
                position = .region(
                    MKCoordinateRegion(
                        center: payload.targetLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
            }
            .overlay {
                if isAcceptedSuccess || isDeclinedSuccess {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(isAcceptedSuccess ? Color.green.opacity(0.2) : Color.white.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: isAcceptedSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(isAcceptedSuccess ? .green : .white)
                            }
                            
                            Text(isAcceptedSuccess ? "Accepted!" : "Declined")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(isAcceptedSuccess ? "Your location will be shared with the host." : "The host has been notified.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(40)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isAcceptedSuccess)
            .animation(.easeInOut(duration: 0.3), value: isDeclinedSuccess)
        }
    }
    
    // High-Contrast Input Helper
    private func highContrastTextField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20)
            
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .accentColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func submitResponse(status: ParticipantStatus) {
        let name = participantName.isEmpty ? "Invited Friend" : participantName
        let contact = emailInput.isEmpty ? contactInfo : emailInput
        let finalContact = contact.isEmpty ? "Not provided" : contact
        let origin = originLocationName.isEmpty ? "Location" : originLocationName
        
        let coord = locationManager.userLocation ?? CLLocationCoordinate2D(
            latitude: payload.targetLocation.latitude + 0.015,
            longitude: payload.targetLocation.longitude - 0.02
        )
        
        meetingStore.respondToInvite(
            meetingID: payload.id,
            participantName: name,
            contactInfo: finalContact,
            originLocationName: origin,
            status: status,
            coordinate: status == .accepted ? coord : nil
        )
        
        withAnimation {
            if status == .accepted {
                isAcceptedSuccess = true
            } else {
                isDeclinedSuccess = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}
