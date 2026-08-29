import Foundation
import Combine

/// Generic countdown engine that plays through an ordered list of
/// `RunningPhase`-shaped steps (used by both the abs/strength timer and the
/// running timer, via `TimedStep`). Ticks every 0.1s for a smooth ring
/// animation, beeps on every transition, and auto-advances.
struct TimedStep: Identifiable, Equatable {
    let id: UUID
    let title: String        // "RA", "Descanso", "Plancha lateral"...
    let subtitle: String?    // extra context, e.g. the exercise name
    let seconds: Int?        // nil => manual-advance / stopwatch step
    let accent: StepAccent

    init(id: UUID = UUID(), title: String, subtitle: String?, seconds: Int?, accent: StepAccent) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.seconds = seconds
        self.accent = accent
    }

    enum StepAccent: String, Equatable {
        case work, rest, walk, info
    }
}

final class IntervalTimerEngine: ObservableObject {
    @Published private(set) var steps: [TimedStep]
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var remaining: Double = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var elapsedInManualStep: Double = 0 // for distance/stopwatch steps
    @Published private(set) var totalActiveElapsed: Double = 0

    private var timer: AnyCancellable?
    private let beeper = BeepPlayer()

    init(steps: [TimedStep]) {
        self.steps = steps
        if let first = steps.first {
            remaining = Double(first.seconds ?? 0)
        }
    }

    var currentStep: TimedStep? {
        steps.indices.contains(currentIndex) ? steps[currentIndex] : nil
    }

    var nextStep: TimedStep? {
        steps.indices.contains(currentIndex + 1) ? steps[currentIndex + 1] : nil
    }

    var progress: Double {
        guard let total = currentStep?.seconds, total > 0 else { return 0 }
        return 1 - (remaining / Double(total))
    }

    func start() {
        guard !isFinished else { return }
        isRunning = true
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    /// Manually completes a distance/stopwatch step (no fixed duration).
    func markManualStepDone() {
        beeper.playTransition()
        advance()
    }

    func skip() {
        beeper.playTransition()
        advance()
    }

    func reset() {
        pause()
        currentIndex = 0
        isFinished = false
        elapsedInManualStep = 0
        totalActiveElapsed = 0
        remaining = Double(steps.first?.seconds ?? 0)
    }

    private func tick() {
        guard let step = currentStep else { return }
        totalActiveElapsed += 0.1
        guard let total = step.seconds else {
            elapsedInManualStep += 0.1
            return
        }
        _ = total
        remaining -= 0.1
        if remaining <= 0 {
            beeper.playTransition()
            advance()
        }
    }

    private func advance() {
        elapsedInManualStep = 0
        if currentIndex + 1 < steps.count {
            currentIndex += 1
            remaining = Double(steps[currentIndex].seconds ?? 0)
        } else {
            pause()
            isFinished = true
            beeper.playFinish()
        }
    }
}
