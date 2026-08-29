import Combine
import SwiftUI

struct RunningWorkoutPlayerView: View {
    let session: RunningSession
    @StateObject private var engine: IntervalTimerEngine
    @Environment(\.dismiss) private var dismiss
    @State private var didSaveWorkout = false
    @State private var saveError: String?
    private let liveSessionID = UUID()
    private let watchPlan: WatchWorkoutPlan

    init(session: RunningSession) {
        self.session = session
        self.watchPlan = WatchWorkoutPlan(session: session)
        _engine = StateObject(wrappedValue: IntervalTimerEngine(steps: session.phases.map(Self.step))) 
    }

    private static func step(from phase: RunningPhase) -> TimedStep {
        let accent: TimedStep.StepAccent
        switch phase.kind {
        case .ritmoAlto: accent = .work
        case .ritmoMedio: accent = .work
        case .ritmoSuave: accent = .rest
        case .caminar: accent = .walk
        case .distancia, .nota, .cronometro: accent = .info
        }
        let title: String
        switch phase.kind {
        case .distancia: title = "\(phase.meters ?? 0) m — \(phase.kind.displayName)"
        case .nota: title = phase.note ?? phase.kind.displayName
        default: title = phase.kind.displayName
        }
        return TimedStep(title: title, subtitle: phase.kind.shortLabel, seconds: phase.seconds, accent: accent)
    }

    var body: some View {
        VStack(spacing: DS.Spacing.xl) {
            if engine.isFinished {
                CompletionView { dismiss() }
            } else if let step = engine.currentStep {
                let accentColor = colorFor(step)

                Text("\(engine.currentIndex + 1) / \(engine.steps.count)")
                    .font(.subheadline).foregroundStyle(.secondary)

                Text(step.subtitle ?? "")
                    .font(.system(size: DS.FontSize.title, weight: .heavy, design: .rounded))
                    .foregroundStyle(accentColor)

                if step.seconds != nil {
                    RingProgressView(
                        progress: engine.progress,
                        accentColor: accentColor,
                        isRunning: engine.isRunning,
                        centerText: formatted(Int(engine.remaining.rounded(.up))),
                        centerSubtext: step.title
                    )
                    .frame(maxWidth: 280)
                } else {
                    VStack(spacing: DS.Spacing.md) {
                        Text(step.title)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text(formatted(Int(engine.elapsedInManualStep)))
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .monospacedDigit()
                        Button {
                            engine.markManualStepDone()
                        } label: {
                            Label("Hecho — siguiente", systemImage: "checkmark")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 40)
                }

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
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            PhoneWatchConnectivity.shared.onCommand = handleWatchCommand
            engine.start()
            publishLiveState()
        }
        .onReceive(engine.$remaining.throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true)) { _ in
            publishLiveState()
        }
        .onChange(of: engine.currentIndex) { _, _ in publishLiveState(durable: true) }
        .onChange(of: engine.isRunning) { _, _ in publishLiveState(durable: true) }
        .onDisappear {
            PhoneWatchConnectivity.shared.onCommand = nil
            PhoneWatchConnectivity.shared.endLiveSession(id: liveSessionID)
        }
        .onChange(of: engine.isFinished) { _, isFinished in
            guard isFinished, !didSaveWorkout else { return }
            didSaveWorkout = true
            Task {
                do {
                    try await SupabaseService.shared.saveRunningWorkout(
                        session: session,
                        durationSeconds: Int(engine.totalActiveElapsed.rounded())
                    )
                } catch {
                    saveError = error.localizedDescription
                }
            }
        }
        .alert("No se pudo guardar la carrera", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(saveError ?? "Inténtalo de nuevo más tarde.")
        }
    }

    private func publishLiveState(durable: Bool = false) {
        PhoneWatchConnectivity.shared.publish(liveState: WatchWorkoutLiveState(
            id: liveSessionID,
            plan: watchPlan,
            currentStepIndex: engine.currentIndex,
            remainingSeconds: engine.remaining,
            elapsedSeconds: engine.totalActiveElapsed,
            isRunning: engine.isRunning,
            isFinished: engine.isFinished
        ), durable: durable)
    }

    private func handleWatchCommand(_ command: WatchWorkoutCommand) {
        guard command.sessionID == liveSessionID else { return }
        switch command.action {
        case .toggle: engine.toggle()
        case .skip: engine.skip()
        }
        publishLiveState(durable: true)
    }

    private func colorFor(_ step: TimedStep) -> Color {
        switch step.subtitle {
        case "RA": return DS.Colors.ritmoAlto
        case "RM": return DS.Colors.ritmoMedio
        case "RS": return DS.Colors.ritmoSuave
        default: return PhaseColor.color(for: step.accent)
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

    private func formatted(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
