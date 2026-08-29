import SwiftUI

struct WatchHomeView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager

    var body: some View {
        NavigationStack {
            Group {
                if connectivity.plans.isEmpty {
                    ContentUnavailableView(
                        "Sin entrenamientos",
                        systemImage: "iphone.and.arrow.forward",
                        description: Text("Abre Fit Flow en el iPhone para sincronizar tus planes.")
                    )
                } else {
                    List {
                        planSection(title: "Abdominales", kind: .abs)
                        planSection(title: "Carrera", kind: .running)
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
            }
            .navigationDestination(for: WatchWorkoutPlan.self) { plan in
                WatchWorkoutPlayerView(plan: plan)
            }
            .fullScreenCover(isPresented: Binding(
                get: { connectivity.liveState != nil },
                set: { if !$0 { connectivity.dismissLiveSession() } }
            )) {
                WatchMirroredWorkoutView()
                    .environmentObject(connectivity)
            }
        }
    }

    @ViewBuilder
    private func planSection(title: String, kind: WatchWorkoutKind) -> some View {
        let plans = connectivity.plans.filter { $0.kind == kind }
        if !plans.isEmpty {
            Section(title) {
                ForEach(plans) { plan in
                    NavigationLink(value: plan) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(plan.title).font(.headline)
                            Text(plan.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}
