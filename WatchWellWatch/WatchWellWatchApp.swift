import SwiftUI

@main
struct WatchWellWatchApp: App {
    @StateObject private var connectivity = ConnectivityManager.shared

    init() {
        ConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(connectivity)
        }
    }
}
