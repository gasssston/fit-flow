import SwiftUI

struct WatchWorkoutPlayerView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine: WatchWorkoutEngine
    @State private var didSendResult = false

    init(plan: WatchWorkoutPlan) {
        _engine = StateObject(wrappedValue: WatchWorkoutEngine(plan: plan))
    }

    var body: some View {
        Group {
            if engine.isFinished {
                completion
            } else if let step = engine.currentStep {
                phaseView(step)
            }
        }
        .navigationBarBackButtonHidden(engine.isRunning)
        .onAppear { engine.start() }
        .onChange(of: engine.isFinished) { _, finished in
            guard finished, !didSendResult else { return }
            didSendResult = true
            connectivity.send(engine.makeResult())
        }
    }

    private func phaseView(_ step: WatchWorkoutStep) -> some View {
        VStack(spacing: 5) {
            Text("\(engine.currentIndex + 1) / \(engine.plan.steps.count)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ZStack {
                Circle().stroke(.white.opacity(0.12), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: step.durationSeconds == nil ? 1 : engine.progress)
                    .stroke(color(for: step.style), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text(primaryValue(for: step))
                        .font(.headline.monospacedDigit().bold())
                    stepVisual(step)
                }
                .padding(7)
            }
            .frame(width: 118, height: 118)

            if let next = engine.nextStep {
                Text("Siguiente: \(next.title)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 10) {
                Button(action: engine.toggle) {
                    Image(systemName: engine.isRunning ? "pause.fill" : "play.fill")
                }
                .tint(.orange)

                Button(action: engine.advance) {
                    Image(systemName: "forward.end.fill")
                }
                .tint(.blue)
            }
            .buttonStyle(.bordered)
            .labelStyle(.iconOnly)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func stepVisual(_ step: WatchWorkoutStep) -> some View {
        if step.style == .work, let animationID = step.detail {
            ExerciseVisualizerView(
                animation: StickmanPoseLibrary.animation(for: animationID),
                strokeColor: .white,
                jointColor: color(for: step.style)
            )
            .frame(width: 70, height: 70)
        } else {
            Image(systemName: step.style == .rest ? "figure.cooldown" : "figure.run")
                .font(.system(size: 34))
                .foregroundStyle(color(for: step.style))
        }
    }

    private var completion: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("¡Completado!").font(.headline)
            Text(format(Int(engine.elapsed.rounded())))
                .font(.title3.monospacedDigit())
            Button("Listo") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func primaryValue(for step: WatchWorkoutStep) -> String {
        if let distance = step.distanceMeters { return "\(distance) m" }
        if step.durationSeconds == nil { return format(Int(engine.elapsed.rounded())) }
        return format(Int(engine.remaining.rounded(.up)))
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func color(for style: WatchWorkoutStepStyle) -> Color {
        switch style {
        case .work: .orange
        case .rest: .green
        case .walk: .cyan
        case .info: .blue
        }
    }
}
