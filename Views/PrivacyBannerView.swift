import SwiftUI

struct PrivacyBannerView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Extreme Privacy Active")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Your location is ONLY shared for the next 2 hours, and ONLY with people in this specific invite link.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    PrivacyBannerView(isPresented: .constant(true))
}
