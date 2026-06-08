import SwiftUI

struct ContactBottomSheetView: View {
    @ObservedObject var viewModel: MapViewModel
    var onNudge: ((User) -> Void)? = nil
    
    var body: some View {
        NavigationView {
            List(viewModel.friends) { friend in
                NavigationLink(destination: ContactDetailView(viewModel: viewModel, friend: friend, onNudge: onNudge)) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 40, height: 40)
                            Text(String(friend.name.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .font(.headline)
                            Text("Distance to meeting: \(viewModel.distance(from: friend))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            onNudge?(friend)
                        }) {
                            Text("Nudge")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        viewModel.selectedFriend = friend
                    } label: {
                        Label("View on Map", systemImage: "map.fill")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        onNudge?(friend)
                    } label: {
                        Label("Nudge", systemImage: "hand.point.right.fill")
                    }
                    .tint(.orange)
                }
            }
            .navigationTitle("Invited Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContactBottomSheetView(viewModel: MapViewModel())
}
