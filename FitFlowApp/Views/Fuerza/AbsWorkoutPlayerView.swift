import SwiftUI

struct AbsWorkoutPlayerView: View {
    @StateObject private var engine: IntervalTimerEngine
    @Environment(\.dismiss) private var dismiss

    init(steps: [TimedStep]) {
        _engine = StateObject(wrappedValue: IntervalTimerEngine(steps: steps))
    }

    var body: some View {
        VStack(spacing: 20) {
            if engine.isFinished {
                CompletionView { dismiss() }
            } else if let step = engine.currentStep {
                let accentColor = PhaseColor.color(for: step.accent)

                Text("\(engine.currentIndex + 1) / \(engine.steps.count)")
                    .font(.subheadline).foregroundStyle(.secondary)

                if step.accent == .work, let animId = step.subtitle {
                    StickmanView(animation: StickmanPoseLibrary.animation(for: animId), strokeColor: .primary, jointColor: accentColor)
                        .frame(maxHeight: 220)
                        .padding(.top, 4)
                } else {
                    Image(systemName: "figure.cooldown")
                        .font(.system(size: 90))
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
