import SwiftUI

@main
struct MultipleMapsApp: App {
    var body: some Scene {
        WindowGroup {
            MainMapView()
                .onOpenURL { url in
                    // In a full implementation, the URL is handled in MainMapView
                    // via .onOpenURL, but global handling can also reside here.
                    print("Received deep link: \(url)")
                }
        }
    }
}
