import SwiftUI

@main
struct FitFlowApp: App {
    @StateObject private var appState = AppState()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isAuthenticated {
                    HomeView()
                        .environmentObject(appState)
                        .transition(.opacity)
                } else {
                    AuthView()
                        .environmentObject(appState)
                        .transition(.opacity)
                }

                if showSplash {
                    SplashView(isSplashActive: $showSplash)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .task {
                PhoneWatchConnectivity.shared.activate()
                appState.refreshFromSupabase()
            }
        }
    }
}
