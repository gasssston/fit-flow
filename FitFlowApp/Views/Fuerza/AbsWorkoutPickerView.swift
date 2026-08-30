import SwiftUI

/// Lets the user pick which exercises go into today's ab circuit and the
/// work/rest durations, then launches the player.
/// Supports ad-hoc sessions and creating or editing a saved planning.
struct AbsWorkoutPickerView: View {
    enum Mode {
        case oneByOne
        case createPlanning
        case editPlanning(AbsPlanning)
    }

    let mode: Mode
    let onSave: (Bool) -> Void

    @State private var selectedExerciseIds: [String]
    @State private var workSeconds: Int
    @State private var restSeconds: Int
    @State private var rounds: Int
    @State private var showPlayer = false
    @State private var planningName = ""
    @State private var showSaveAlert = false
    @State private var isSaving = false
    @State private var previewExercise: AbExercise?

    init(mode: Mode = .oneByOne, onSave: @escaping (Bool) -> Void = { _ in }) {
        self.mode = mode
        self.onSave = onSave

        if case let .editPlanning(planning) = mode {
            _selectedExerciseIds = State(initialValue: planning.exerciseIds)
            _workSeconds = State(initialValue: planning.workSeconds)
            _restSeconds = State(initialValue: planning.restSeconds)
            _rounds = State(initialValue: planning.rounds)
            _planningName = State(initialValue: planning.name)
        } else if case .oneByOne = mode {
            _selectedExerciseIds = State(initialValue: AbExerciseLibrary.all.map(\.id))
            _workSeconds = State(initialValue: 20)
            _restSeconds = State(initialValue: 10)
            _rounds = State(initialValue: 1)
        } else {
            _selectedExerciseIds = State(initialValue: [])
            _workSeconds = State(initialValue: 20)
            _restSeconds = State(initialValue: 10)
            _rounds = State(initialValue: 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Duraciones") {
                    Stepper("Trabajo: \(workSeconds)s", value: $workSeconds, in: 5...90, step: 5)
                    Stepper("Descanso: \(restSeconds)s", value: $restSeconds, in: 5...60, step: 5)
                    Stepper("Rondas: \(rounds)", value: $rounds, in: 1...5)
                }

                if !selectedExercises.isEmpty {
                    Section("Orden del circuito") {
                        ForEach(selectedExercises) { exercise in
                            Button {
                                toggle(exercise.id)
                            } label: {
                                ExerciseRow(exercise: exercise, isSelected: true, showsReorderHint: true)
                            }
                            .buttonStyle(.plain)
                        }
                        .onMove(perform: moveExercises)
                    }
                }

                Section(selectedExercises.isEmpty ? "Elige ejercicios" : "Añadir ejercicios") {
                    ForEach(unselectedExercises) { exercise in
                        Button {
                            toggle(exercise.id)
                        } label: {
                            ExerciseRow(exercise: exercise, isSelected: false)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                previewExercise = exercise
                            } label: {
                                Label("Ver en 3D", systemImage: "eye.fill")
                            }
                            .tint(DS.Colors.info)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Colors.canvas)

            VStack(spacing: DS.Spacing.md) {
                if isPlanningMode {
                    Button {
                        showSaveAlert = true
                    } label: {
                        Label("Guardar planificación", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedExerciseIds.isEmpty || isSaving)
                }

                Button {
                    showPlayer = true
                } label: {
                    Label(isPlanningMode ? "Vista previa" : "Empezar circuito", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle(tint: isPlanningMode ? .gray : .accentColor))
                .disabled(selectedExerciseIds.isEmpty)
            }
            .padding(DS.Spacing.lg)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            if selectedExerciseIds.count > 1 {
                EditButton()
            }
        }
        .navigationDestination(isPresented: $showPlayer) {
            AbsWorkoutPlayerView(steps: buildSteps(), configuration: workoutConfiguration)
        }
        .alert("Nombre de la planificación", isPresented: $showSaveAlert) {
            TextField("Ej: Rutina diaria", text: $planningName)
            Button("Guardar") {
                savePlanning()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Dale un nombre a tu circuito para poder reutilizarlo.")
        }
        .sheet(item: $previewExercise) { exercise in
            Exercise3DPreviewView(exercise: exercise)
        }
    }

    private func toggle(_ id: String) {
        if let index = selectedExerciseIds.firstIndex(of: id) {
            selectedExerciseIds.remove(at: index)
        } else {
            selectedExerciseIds.append(id)
        }
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        selectedExerciseIds.move(fromOffsets: source, toOffset: destination)
    }

    private var selectedExercises: [AbExercise] {
        selectedExerciseIds.compactMap { id in
            AbExerciseLibrary.all.first { $0.id == id }
        }
    }

    private var unselectedExercises: [AbExercise] {
        AbExerciseLibrary.all.filter { !selectedExerciseIds.contains($0.id) }
    }

    private var isPlanningMode: Bool {
        if case .oneByOne = mode { return false }
        return true
    }

    private var navigationTitle: String {
        switch mode {
        case .oneByOne: "Abdominales"
        case .createPlanning: "Nueva planificación"
        case .editPlanning: "Editar planificación"
        }
    }

    private func buildSteps() -> [TimedStep] {
        let exercises = selectedExercises
        var steps: [TimedStep] = []
        for _ in 0..<rounds {
            for (index, exercise) in exercises.enumerated() {
                steps.append(TimedStep(title: exercise.name, subtitle: exercise.id, seconds: workSeconds, accent: .work))
                let nextExercise = index + 1 < exercises.count ? exercises[index + 1] : exercises.first
                let restTitle = nextExercise.map { "Descanso → \($0.name)" } ?? "Descanso"
                steps.append(TimedStep(title: restTitle, subtitle: nextExercise?.id, seconds: restSeconds, accent: .rest))
            }
        }
        if steps.last?.accent == .rest { steps.removeLast() }
        return steps
    }

    private var workoutConfiguration: AbWorkoutConfiguration {
        AbWorkoutConfiguration(
            exerciseIds: selectedExerciseIds,
            workSeconds: workSeconds,
            restSeconds: restSeconds,
            rounds: rounds
        )
    }

    private func savePlanning() {
        let name = planningName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        isSaving = true
        Task {
            let existingPlanning: AbsPlanning? = if case let .editPlanning(planning) = mode { planning } else { nil }
            let planning = AbsPlanning(
                id: existingPlanning?.id ?? UUID(),
                userId: existingPlanning?.userId ?? SupabaseService.shared.currentUserID,
                name: name,
                exerciseIds: selectedExerciseIds,
                workSeconds: workSeconds,
                restSeconds: restSeconds,
                rounds: rounds
            )
            do {
                try await SupabaseService.shared.savePlanning(planning)
                onSave(true)
            } catch {
                print("Failed to save planning: \(error)")
                onSave(false)
            }
            isSaving = false
        }
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: AbExercise
    let isSelected: Bool
    var showsReorderHint = false

    var body: some View {
        HStack {
            ExerciseVisualizerView(
                animation: StickmanPoseLibrary.animation(for: exercise.id),
                strokeColor: DS.Colors.brandMid,
                jointColor: DS.Colors.brandStart
            )
                .frame(width: DS.IconSize.exerciseThumb, height: DS.IconSize.exerciseThumb)
            Text(exercise.name)
            Spacer()
            Image(systemName: showsReorderHint ? "line.3.horizontal" : (isSelected ? "checkmark.circle.fill" : "plus.circle"))
                .foregroundStyle(isSelected ? DS.Colors.brandMid : .secondary)
        }
    }
}

private struct Exercise3DPreviewView: View {
    let exercise: AbExercise

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Model3DView(animation: StickmanPoseLibrary.animation(for: exercise.id))
                .padding(.bottom, 80)
                .background(
                    LinearGradient(
                        colors: [DS.Colors.brandStart.opacity(0.12), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .bottom) {
                    Label("Arrastra para girar · Pellizca para ampliar", systemImage: "hand.draw")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .navigationTitle(exercise.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar") { dismiss() }
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
