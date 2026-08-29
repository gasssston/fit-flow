import SwiftUI

struct WatchMirroredWorkoutView: View {
    @EnvironmentObject private var connectivity: WatchConnectivityManager

    var body: some View {
        ZStack(alignment: .topLeading) {
            TimelineView(.periodic(from: .now, by: 0.2)) { context in
                if let state = connectivity.liveState {
                    if state.isPreparing {
                        preparation(state, at: context.date)
                    } else if state.isFinished {
                        completion(state)
                    } else if state.plan.steps.indices.contains(state.currentStepIndex) {
                        workout(state, at: context.date)
                    }
                }
            }

            Button {
                connectivity.dismissLiveSession()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .frame(width: 28, height: 28)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cerrar entrenamiento del iPhone")
        }
    }

    private func preparation(_ state: WatchWorkoutLiveState, at date: Date) -> some View {
        let remaining = state.remainingSeconds - date.timeIntervalSince(state.updatedAt)
        return VStack(spacing: 10) {
            Image(systemName: "figure.core.training")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Prepárate").font(.headline)
            Text("\(max(1, Int(remaining.rounded(.up))))")
                .font(.system(size: 54, weight: .black, design: .rounded))
                .monospacedDigit()
            Text(state.plan.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private func workout(_ state: WatchWorkoutLiveState, at date: Date) -> some View {
        let step = state.plan.steps[state.currentStepIndex]
        let remaining = displayedRemaining(state, step: step, at: date)

        return VStack(spacing: 5) {
            Text("Desde el iPhone")
                .font(.caption2.bold())
                .foregroundStyle(.green)

            Text("\(state.currentStepIndex + 1) / \(state.plan.steps.count)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ZStack {
                Circle().stroke(.white.opacity(0.12), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: progress(step: step, remaining: remaining))
                    .stroke(color(for: step.style), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text(value(state, step: step, remaining: remaining, at: date))
                        .font(.headline.monospacedDigit().bold())
                    stepVisual(step)
                }
                .padding(7)
            }
            .frame(width: 112, height: 112)

            HStack(spacing: 10) {
                Button {
                    connectivity.send(.toggle, sessionID: state.id)
                } label: {
                    Image(systemName: state.isRunning ? "pause.fill" : "play.fill")
                }
                .tint(.orange)

                Button {
                    connectivity.send(.skip, sessionID: state.id)
                } label: {
                    Image(systemName: "forward.end.fill")
                }
                .tint(.blue)
            }
            .buttonStyle(.bordered)
            .disabled(!connectivity.isPhoneReachable)
        }
    }

    @ViewBuilder
    private func stepVisual(_ step: WatchWorkoutStep) -> some View {
        if step.style == .work, let animationID = step.detail {
            StickmanView(
                animation: StickmanPoseLibrary.animation(for: animationID),
                strokeColor: .white,
                jointColor: color(for: step.style)
            )
            .frame(width: 68, height: 68)
        } else {
            Image(systemName: step.style == .rest ? "figure.cooldown" : "figure.run")
                .font(.system(size: 34))
                .foregroundStyle(color(for: step.style))
        }
    }

    private func completion(_ state: WatchWorkoutLiveState) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("¡Completado!").font(.headline)
            Text(format(Int(state.elapsedSeconds.rounded())))
                .font(.title3.monospacedDigit())
            Text("Finaliza en el iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func displayedRemaining(
        _ state: WatchWorkoutLiveState,
        step: WatchWorkoutStep,
        at date: Date
    ) -> TimeInterval {
        guard state.isRunning, step.durationSeconds != nil else { return state.remainingSeconds }
        return max(0, state.remainingSeconds - date.timeIntervalSince(state.updatedAt))
    }

    private func progress(step: WatchWorkoutStep, remaining: TimeInterval) -> Double {
        guard let duration = step.durationSeconds, duration > 0 else { return 1 }
        return min(max(1 - remaining / Double(duration), 0), 1)
    }

    private func value(
        _ state: WatchWorkoutLiveState,
        step: WatchWorkoutStep,
        remaining: TimeInterval,
        at date: Date
    ) -> String {
        if let distance = step.distanceMeters { return "\(distance) m" }
        if step.durationSeconds != nil { return format(Int(remaining.rounded(.up))) }
        let elapsed = state.elapsedSeconds + (state.isRunning ? max(0, date.timeIntervalSince(state.updatedAt)) : 0)
        return format(Int(elapsed.rounded()))
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
