import SwiftUI

struct ContactDetailView: View {
    @ObservedObject var viewModel: MapViewModel
    let friend: User
    var onNudge: ((User) -> Void)? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 100, height: 100)
                Text(String(friend.name.prefix(1)))
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            Text(friend.name)
                .font(.title)
                .bold()
            
            VStack(spacing: 8) {
                Text("Distance to Meeting Location")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(viewModel.distance(from: friend))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
            
            VStack(spacing: 16) {
                Button(action: {
                    // Set the selected friend to view on map, and pop the view
                    viewModel.selectedFriend = friend
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("View on Map")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                
                Button(action: {
                    onNudge?(friend)
                }) {
                    HStack {
                        Text("👉")
                        Text("Nudge \(friend.name)")
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContactDetailView(viewModel: MapViewModel(), friend: User.mockFriends[0])
}
