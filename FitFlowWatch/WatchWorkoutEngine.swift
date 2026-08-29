import Combine
import Foundation
import WatchKit

@MainActor
final class WatchWorkoutEngine: ObservableObject {
    @Published private(set) var currentIndex = 0
    @Published private(set) var remaining: TimeInterval = 0
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var isRunning = false
    @Published private(set) var isFinished = false

    let plan: WatchWorkoutPlan

    private var timer: AnyCancellable?
    private var phaseStartedAt: Date?
    private var activeStartedAt: Date?
    private var accumulatedPhaseTime: TimeInterval = 0
    private var accumulatedActiveTime: TimeInterval = 0

    init(plan: WatchWorkoutPlan) {
        self.plan = plan
        remaining = TimeInterval(plan.steps.first?.durationSeconds ?? 0)
    }

    var currentStep: WatchWorkoutStep? {
        plan.steps.indices.contains(currentIndex) ? plan.steps[currentIndex] : nil
    }

    var nextStep: WatchWorkoutStep? {
        plan.steps.indices.contains(currentIndex + 1) ? plan.steps[currentIndex + 1] : nil
    }

    var progress: Double {
        guard let duration = currentStep?.durationSeconds, duration > 0 else { return 0 }
        return min(max(1 - remaining / Double(duration), 0), 1)
    }

    func start() {
        guard !isRunning, !isFinished, currentStep != nil else { return }
        let now = Date()
        isRunning = true
        phaseStartedAt = now
        activeStartedAt = now
        timer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in self?.update(at: now) }
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func pause() {
        guard isRunning else { return }
        updateAccumulatedTime(at: Date())
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func advance() {
        if isRunning { updateAccumulatedTime(at: Date()) }
        WKInterfaceDevice.current().play(.click)
        accumulatedPhaseTime = 0

        guard currentIndex + 1 < plan.steps.count else {
            finish()
            return
        }

        currentIndex += 1
        remaining = TimeInterval(currentStep?.durationSeconds ?? 0)
        if isRunning {
            let now = Date()
            phaseStartedAt = now
            activeStartedAt = now
        }
    }

    func makeResult() -> WatchWorkoutResult {
        let completedAt = Date()
        return WatchWorkoutResult(
            planID: plan.id,
            title: plan.title,
            kind: plan.kind,
            startedAt: completedAt.addingTimeInterval(-elapsed),
            completedAt: completedAt,
            activeDurationSeconds: Int(elapsed.rounded()),
            sourceNotation: plan.sourceNotation
        )
    }

    private func update(at now: Date) {
        guard isRunning, let activeStartedAt else { return }
        elapsed = accumulatedActiveTime + now.timeIntervalSince(activeStartedAt)

        guard let duration = currentStep?.durationSeconds, let phaseStartedAt else { return }
        let phaseElapsed = accumulatedPhaseTime + now.timeIntervalSince(phaseStartedAt)
        remaining = max(0, Double(duration) - phaseElapsed)
        if remaining == 0 { advance() }
    }

    private func updateAccumulatedTime(at now: Date) {
        if let activeStartedAt {
            accumulatedActiveTime += now.timeIntervalSince(activeStartedAt)
            elapsed = accumulatedActiveTime
        }
        if let phaseStartedAt {
            accumulatedPhaseTime += now.timeIntervalSince(phaseStartedAt)
        }
        activeStartedAt = nil
        phaseStartedAt = nil
    }

    private func finish() {
        if isRunning {
            isRunning = false
            timer?.cancel()
            timer = nil
            activeStartedAt = nil
            phaseStartedAt = nil
        }
        isFinished = true
        WKInterfaceDevice.current().play(.success)
    }
}
