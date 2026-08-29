import SwiftUI

@main
struct FitFlowWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environmentObject(connectivity)
        }
    }
}
