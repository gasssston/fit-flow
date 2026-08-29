import Combine
import SwiftUI

struct AbsWorkoutPlayerView: View {
    @StateObject private var engine: IntervalTimerEngine
    @Environment(\.dismiss) private var dismiss
    private let configuration: AbWorkoutConfiguration
    private let liveSessionID = UUID()
    private let watchPlan: WatchWorkoutPlan
    @State private var didSaveWorkout = false
    @State private var saveError: String?
    @State private var preparationRemaining = 5
    @State private var preparationTask: Task<Void, Never>?

    init(steps: [TimedStep], configuration: AbWorkoutConfiguration, title: String = "Circuito abdominales") {
        self.configuration = configuration
        self.watchPlan = WatchWorkoutPlan(
            id: UUID(),
            title: title,
            subtitle: "\(configuration.exerciseIds.count) ejercicios · \(configuration.rounds) rondas",
            kind: .abs,
            steps: steps.map(WatchWorkoutStep.init),
            sourceNotation: nil
        )
        _engine = StateObject(wrappedValue: IntervalTimerEngine(steps: steps))
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            if preparationRemaining > 0 {
                VStack(spacing: DS.Spacing.lg) {
                    Text("Prepárate")
                        .font(.title.bold())
                    Text("\(preparationRemaining)")
                        .font(.system(size: DS.FontSize.hero, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text(watchPlan.title)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if engine.isFinished {
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
        .onAppear {
            PhoneWatchConnectivity.shared.onCommand = handleWatchCommand
            startPreparation()
        }
        .onReceive(engine.$remaining.throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true)) { _ in
            publishLiveState()
        }
        .onChange(of: engine.currentIndex) { _, _ in publishLiveState(durable: true) }
        .onChange(of: engine.isRunning) { _, _ in publishLiveState(durable: true) }
        .onDisappear {
            PhoneWatchConnectivity.shared.onCommand = nil
            preparationTask?.cancel()
            PhoneWatchConnectivity.shared.endLiveSession(id: liveSessionID)
        }
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

    private func startPreparation() {
        publishLiveState(durable: true)
        preparationTask = Task {
            for value in stride(from: 4, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                preparationRemaining = value
                publishLiveState(durable: true)
            }
            engine.start()
            publishLiveState(durable: true)
        }
    }

    private func publishLiveState(durable: Bool = false) {
        PhoneWatchConnectivity.shared.publish(liveState: WatchWorkoutLiveState(
            id: liveSessionID,
            plan: watchPlan,
            currentStepIndex: engine.currentIndex,
            remainingSeconds: preparationRemaining > 0 ? Double(preparationRemaining) : engine.remaining,
            elapsedSeconds: engine.totalActiveElapsed,
            isRunning: engine.isRunning,
            isFinished: engine.isFinished,
            isPreparing: preparationRemaining > 0
        ), durable: durable)
    }

    private func handleWatchCommand(_ command: WatchWorkoutCommand) {
        guard command.sessionID == liveSessionID else { return }
        switch command.action {
        case .toggle:
            guard preparationRemaining == 0 else { return }
            engine.toggle()
        case .skip:
            guard preparationRemaining == 0 else { return }
            engine.skip()
        }
        publishLiveState(durable: true)
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
