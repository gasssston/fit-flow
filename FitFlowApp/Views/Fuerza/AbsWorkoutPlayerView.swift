import SwiftUI

struct AbsWorkoutPlayerView: View {
    @StateObject private var engine: IntervalTimerEngine
    @Environment(\.dismiss) private var dismiss
    private let configuration: AbWorkoutConfiguration
    @State private var didSaveWorkout = false
    @State private var saveError: String?

    init(steps: [TimedStep], configuration: AbWorkoutConfiguration) {
        self.configuration = configuration
        _engine = StateObject(wrappedValue: IntervalTimerEngine(steps: steps))
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            if engine.isFinished {
                CompletionView { dismiss() }
            } else if let step = engine.currentStep {
                let accentColor = PhaseColor.color(for: step.accent)

                Text("\(engine.currentIndex + 1) / \(engine.steps.count)")
                    .font(.subheadline).foregroundStyle(.secondary)

                if let animId = step.subtitle {
                    StickmanView(animation: StickmanPoseLibrary.animation(for: animId), strokeColor: .primary, jointColor: accentColor)
                        .frame(maxHeight: 220)
                        .padding(.top, DS.Spacing.xs)
                } else {
                    Image(systemName: "figure.cooldown")
                        .font(.system(size: DS.IconSize.playerIcon))
                        .foregroundStyle(accentColor)
                        .frame(maxHeight: 220)
                }

                RingProgressView(
                    progress: engine.progress,
                    accentColor: accentColor,
                    isRunning: engine.isRunning,
                    centerText: "\(Int(engine.remaining.rounded(.up)))",
                    centerSubtext: step.title
                )
                .frame(maxWidth: 280)

                if let next = engine.nextStep {
                    Text("Siguiente: \(next.title)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                controls
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [(engine.currentStep.map { PhaseColor.color(for: $0.accent) } ?? .accentColor).opacity(0.12), .clear],
                            startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .navigationTitle("Circuito de abdominales")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { engine.start() }
        .onChange(of: engine.isFinished) { _, isFinished in
            guard isFinished, !didSaveWorkout else { return }
            didSaveWorkout = true
            Task {
                do {
                    try await SupabaseService.shared.saveAbWorkout(
                        configuration: configuration,
                        durationSeconds: Int(engine.totalActiveElapsed.rounded())
                    )
                } catch {
                    saveError = error.localizedDescription
                }
            }
        }
        .alert("No se pudo guardar el entrenamiento", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(saveError ?? "Inténtalo de nuevo más tarde.")
        }
    }

    private var controls: some View {
        HStack(spacing: DS.Spacing.xl) {
            PlayerControlButton(
                systemName: engine.isRunning ? "pause.fill" : "play.fill",
                action: { engine.toggle() }
            )
            PlayerControlButton(
                systemName: "forward.end.fill",
                size: 52,
                font: .title2,
                action: { engine.skip() }
            )
        }
        .padding(.bottom, DS.Spacing.md)
    }
}

struct CompletionView: View {
    let onDone: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 72))
                .foregroundStyle(.orange)
            Text("¡Circuito completado!")
                .font(.title.bold())
            Text("Buen trabajo. A por el siguiente.")
                .foregroundStyle(.secondary)
            Button("Volver", action: onDone)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
