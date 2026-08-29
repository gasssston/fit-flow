import SwiftUI

/// Root view for the Abs tab: shows saved plannings and a "one by one" option.
struct AbsPlanningsListView: View {
    @State private var plannings: [AbsPlanning] = []
    @State private var isLoading = true
    @State private var showNewPlanning = false
    @State private var showOneByOne = false
    @State private var planningToPlay: AbsPlanning?
    @State private var planningToEdit: AbsPlanning?
    @State private var showPlayer = false
    @State private var toast: SaveToast?

    var body: some View {
        List {
            Section {
                Button {
                    showOneByOne = true
                } label: {
                    Label("Entrenar uno por uno", systemImage: "list.bullet")
                }
            }

            Section("Mis planificaciones") {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if plannings.isEmpty {
                    Text("No hay planificaciones guardadas.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(plannings) { planning in
                        Button {
                            planningToPlay = planning
                            showPlayer = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(planning.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(planning.exerciseIds.count) ejercicios · \(planning.workSeconds)s trabajo · \(planning.restSeconds)s descanso · \(planning.rounds) rondas")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(planning)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }

                            Button {
                                planningToEdit = planning
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            .tint(DS.Colors.info)
                        }
                    }
                }
            }
        }
        .navigationTitle("Abdominales")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewPlanning = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $showOneByOne) {
            AbsWorkoutPickerView()
        }
        .navigationDestination(isPresented: $showNewPlanning) {
            AbsWorkoutPickerView(mode: .createPlanning, onSave: finishSaving)
        }
        .navigationDestination(item: $planningToEdit) { planning in
            AbsWorkoutPickerView(mode: .editPlanning(planning), onSave: finishSaving)
        }
        .navigationDestination(isPresented: $showPlayer) {
            if let planning = planningToPlay {
                AbsPlanningStartView(planning: planning)
            }
        }
        .task {
            await loadPlannings()
        }
        .overlay(alignment: .top) {
            if let toast {
                Label(toast.message, systemImage: toast.isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.md)
                    .background(toast.isError ? Color.red : DS.Colors.brandEnd, in: Capsule())
                    .padding(.top, DS.Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: toast)
    }

    private func loadPlannings() async {
        isLoading = true
        do {
            plannings = try await SupabaseService.shared.fetchPlannings()
            PhoneWatchConnectivity.shared.publish(absPlannings: plannings)
        } catch {
            print("Failed to load plannings: \(error)")
        }
        isLoading = false
    }

    private func delete(_ planning: AbsPlanning) {
        Task {
            do {
                try await SupabaseService.shared.deletePlanning(id: planning.id)
                plannings.removeAll { $0.id == planning.id }
                PhoneWatchConnectivity.shared.publish(absPlannings: plannings)
            } catch {
                print("Failed to delete planning: \(error)")
            }
        }
    }

    private func finishSaving(succeeded: Bool) {
        showNewPlanning = false
        planningToEdit = nil
        showToast(succeeded
            ? SaveToast(message: "Planificación guardada", isError: false)
            : SaveToast(message: "No se pudo guardar la planificación", isError: true))

        if succeeded {
            Task { await loadPlannings() }
        }
    }

    private func showToast(_ newToast: SaveToast) {
        toast = newToast
        Task {
            try? await Task.sleep(for: .seconds(3))
            if toast == newToast { toast = nil }
        }
    }
}

private struct SaveToast: Equatable {
    let message: String
    let isError: Bool
}

private struct AbsPlanningStartView: View {
    let planning: AbsPlanning

    @State private var showWorkout = false

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Image(systemName: "figure.core.training")
                .font(.system(size: DS.IconSize.playerIcon))
                .foregroundStyle(LinearGradient.brandGradient)

            Text("Vas a empezar")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(planning.name)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("\(planning.exerciseIds.count) ejercicios · \(planning.rounds) rondas")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                startCountdown()
            } label: {
                Label("Empezar", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(DS.Spacing.xl)
        .navigationTitle(planning.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showWorkout) {
            AbsWorkoutPlayerView(
                steps: planning.steps,
                configuration: AbWorkoutConfiguration(
                    exerciseIds: planning.exerciseIds,
                    workSeconds: planning.workSeconds,
                    restSeconds: planning.restSeconds,
                    rounds: planning.rounds
                ),
                title: planning.name
            )
        }
    }

    private func startCountdown() {
        showWorkout = true
    }
}
