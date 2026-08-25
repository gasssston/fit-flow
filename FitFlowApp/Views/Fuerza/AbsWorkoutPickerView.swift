import SwiftUI

/// Lets the user pick which exercises go into today's ab circuit and the
/// work/rest durations, then launches the player.
struct AbsWorkoutPickerView: View {
    @State private var selected: Set<String> = Set(AbExerciseLibrary.all.map(\.id))
    @State private var workSeconds: Int = 20
    @State private var restSeconds: Int = 10
    @State private var rounds: Int = 1
    @State private var showPlayer = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Duraciones") {
                    Stepper("Trabajo: \(workSeconds)s", value: $workSeconds, in: 5...90, step: 5)
                    Stepper("Descanso: \(restSeconds)s", value: $restSeconds, in: 5...60, step: 5)
                    Stepper("Rondas: \(rounds)", value: $rounds, in: 1...5)
                }

                Section("Ejercicios") {
                    ForEach(AbExerciseLibrary.all) { exercise in
                        Button {
                            toggle(exercise.id)
                        } label: {
                            HStack {
                                StickmanView(animation: StickmanPoseLibrary.animation(for: exercise.id))
                                    .frame(width: 44, height: 44)
                                Text(exercise.name)
                                Spacer()
                                Image(systemName: selected.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(exercise.id) ? Color.accentColor : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Button {
                        showPlayer = true
                    } label: {
                        Label("Empezar circuito", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selected.isEmpty)
                }
            }
            .navigationTitle("Abdominales")
            .navigationDestination(isPresented: $showPlayer) {
                AbsWorkoutPlayerView(steps: buildSteps())
            }
        }
    }

    private func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }

    private func buildSteps() -> [TimedStep] {
        let exercises = AbExerciseLibrary.all.filter { selected.contains($0.id) }
        var steps: [TimedStep] = []
        for _ in 0..<rounds {
            for exercise in exercises {
                steps.append(TimedStep(title: exercise.name, subtitle: exercise.id, seconds: workSeconds, accent: .work))
                steps.append(TimedStep(title: "Descanso", subtitle: nil, seconds: restSeconds, accent: .rest))
            }
        }
        // Drop the trailing rest after the very last exercise.
        if steps.last?.accent == .rest { steps.removeLast() }
        return steps
    }
}
