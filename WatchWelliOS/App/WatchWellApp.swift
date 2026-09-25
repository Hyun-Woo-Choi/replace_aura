import SwiftUI

@main
struct WatchWellApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(model)
                .task { await model.start() }
        }
    }
}
