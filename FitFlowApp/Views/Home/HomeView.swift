import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)

            NavigationStack {
                AbsPlanningsListView()
            }
            .tabItem {
                Label("Abdominales", systemImage: "flame.fill")
            }
            .tag(1)

            NavigationStack {
                RunningWorkoutPickerView()
            }
            .tabItem {
                Label("Carrera", systemImage: "figure.run")
            }
            .tag(2)

            ProfileView()
                .environmentObject(appState)
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(DS.Colors.brandMid)
        .preferredColorScheme(.dark)
        .toolbarBackground(DS.Colors.canvas.opacity(0.96), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
