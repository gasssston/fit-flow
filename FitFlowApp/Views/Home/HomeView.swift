import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AbsWorkoutPickerView()
                    } label: {
                        Label("Circuito de abdominales", systemImage: "flame.fill")
                    }
                    NavigationLink {
                        RunningWorkoutPickerView()
                    } label: {
                        Label("Entrenos de carrera", systemImage: "figure.run")
                    }
                }

                Section {
                    if let email = appState.userEmail {
                        Text(email).foregroundStyle(.secondary)
                    }
                    Button("Cerrar sesión", role: .destructive) {
                        Task {
                            try? await SupabaseService.shared.signOut()
                            appState.refreshFromSupabase()
                        }
                    }
                }
            }
            .navigationTitle("FitFlow")
        }
    }
}
