import SwiftUI

struct RunningWorkoutPlayerView: View {
    let session: RunningSession
    @StateObject private var engine: IntervalTimerEngine
    @Environment(\.dismiss) private var dismiss

    init(session: RunningSession) {
        self.session = session
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
        VStack(spacing: 20) {
            if engine.isFinished {
                CompletionView { dismiss() }
            } else if let step = engine.currentStep {
                let accentColor = colorFor(step)

                Text("\(engine.currentIndex + 1) / \(engine.steps.count)")
                    .font(.subheadline).foregroundStyle(.secondary)

                Text(step.subtitle ?? "")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
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
                    // Distance segment, free note, or open stopwatch: no fixed
                    // duration — count elapsed time up and let the user advance.
                    VStack(spacing: 12) {
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
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
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
        .onAppear { engine.start() }
    }

    private func colorFor(_ step: TimedStep) -> Color {
        switch step.subtitle {
        case "RA": return .red
        case "RM": return .orange
        case "RS": return .green
        default: return PhaseColor.color(for: step.accent)
        }
    }

    private var controls: some View {
        HStack(spacing: 28) {
            Button {
                engine.toggle()
            } label: {
                Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 64, height: 64)
                    .background(.thinMaterial, in: Circle())
            }
            Button {
                engine.skip()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .frame(width: 52, height: 52)
                    .background(.thinMaterial, in: Circle())
            }
        }
        .padding(.bottom, 12)
    }

    private func formatted(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
