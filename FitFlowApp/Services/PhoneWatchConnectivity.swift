import Combine
import Foundation
import WatchConnectivity

@MainActor
final class PhoneWatchConnectivity: NSObject, ObservableObject {
    static let shared = PhoneWatchConnectivity()

    @Published private(set) var isWatchAvailable = false
    @Published private(set) var latestResult: WatchWorkoutResult?

    var onCommand: ((WatchWorkoutCommand) -> Void)?

    private let session: WCSession?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var catalogData: Data?
    private var liveStateData: Data?
    private var lastDurableLiveUpdate = Date.distantPast
    private var immediateSendInFlight = false
    private var pendingImmediateData: Data?

    private override init() {
        session = WCSession.isSupported() ? .default : nil
        super.init()
    }

    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
        updateAvailability(session)
    }

    func publish(absPlannings: [AbsPlanning]) {
        guard let session else { return }

        let absPlans = absPlannings.map(WatchWorkoutPlan.init)
        let runningPlans = RunningWorkoutLibrary.blocks.flatMap { block in
            block.days.map { WatchWorkoutPlan(session: $0.makeSession(blockName: block.name)) }
        }
        let catalog = WatchWorkoutCatalog(plans: absPlans + runningPlans)

        do {
            catalogData = try encoder.encode(catalog)
            guard canSynchronize(with: session) else { return }
            try updateApplicationContext()
        } catch {
            print("Failed to synchronize Watch catalog: \(error)")
        }
    }

    func publish(liveState: WatchWorkoutLiveState, durable: Bool = false) {
        guard let session, canSynchronize(with: session) else { return }
        do {
            liveStateData = try encoder.encode(WatchWorkoutLiveEnvelope(state: liveState))
            sendImmediateLiveStateIfPossible()
            if durable || Date().timeIntervalSince(lastDurableLiveUpdate) >= 5 {
                try updateApplicationContext()
                lastDurableLiveUpdate = Date()
            }
        } catch {
            print("Failed to synchronize active Watch workout: \(error)")
        }
    }

    func endLiveSession(id: UUID) {
        guard let session, canSynchronize(with: session) else { return }
        do {
            liveStateData = try encoder.encode(WatchWorkoutLiveEnvelope(state: nil))
            try updateApplicationContext()
            sendImmediateLiveStateIfPossible()
        } catch {
            print("Failed to end active Watch workout: \(error)")
        }
    }

    private func updateApplicationContext() throws {
        guard let session, canSynchronize(with: session) else { return }
        var context: [String: Any] = [:]
        context[WatchSyncKey.catalog] = catalogData
        context[WatchSyncKey.liveState] = liveStateData
        try session.updateApplicationContext(context)
    }

    private func sendImmediateLiveStateIfPossible() {
        guard let session, canSynchronize(with: session), session.isReachable, let liveStateData else { return }
        pendingImmediateData = liveStateData
        guard !immediateSendInFlight else { return }
        sendNextImmediateState(using: session)
    }

    private func sendNextImmediateState(using session: WCSession) {
        guard session.isReachable, let data = pendingImmediateData else {
            immediateSendInFlight = false
            return
        }
        pendingImmediateData = nil
        immediateSendInFlight = true
        session.sendMessage([WatchSyncKey.liveState: data]) { [weak self] _ in
            Task { @MainActor in self?.finishImmediateSend(using: session) }
        } errorHandler: { [weak self] error in
            print("Failed to send immediate Watch workout state: \(error)")
            Task { @MainActor in self?.finishImmediateSend(using: session) }
        }
    }

    private func finishImmediateSend(using session: WCSession) {
        immediateSendInFlight = false
        sendNextImmediateState(using: session)
    }

    private func updateAvailability(_ session: WCSession) {
        let wasAvailable = isWatchAvailable
        isWatchAvailable = canSynchronize(with: session)
        if isWatchAvailable, !wasAvailable, catalogData != nil {
            try? updateApplicationContext()
        }
    }

    private func canSynchronize(with session: WCSession) -> Bool {
        session.activationState == .activated && session.isPaired && session.isWatchAppInstalled
    }

    private func receive(resultData: Data) {
        do {
            latestResult = try decoder.decode(WatchWorkoutResult.self, from: resultData)
        } catch {
            print("Failed to decode Watch workout result: \(error)")
        }
    }
}

extension PhoneWatchConnectivity: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        Task { @MainActor in self.updateAvailability(session) }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in self.updateAvailability(session) }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo[WatchSyncKey.result] as? Data else { return }
        Task { @MainActor in self.receive(resultData: data) }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message[WatchSyncKey.command] as? Data else { return }
        Task { @MainActor in
            do {
                let command = try self.decoder.decode(WatchWorkoutCommand.self, from: data)
                self.onCommand?(command)
            } catch {
                print("Failed to decode Watch workout command: \(error)")
            }
        }
    }
}

extension WatchWorkoutPlan {
    init(planning: AbsPlanning) {
        self.init(
            id: planning.id,
            title: planning.name,
            subtitle: "\(planning.exerciseIds.count) ejercicios · \(planning.rounds) rondas",
            kind: .abs,
            steps: planning.steps.map(WatchWorkoutStep.init),
            sourceNotation: nil
        )
    }

    init(session: RunningSession) {
        self.init(
            id: session.id,
            title: session.title,
            subtitle: session.rawNotation,
            kind: .running,
            steps: session.phases.map(WatchWorkoutStep.init),
            sourceNotation: session.rawNotation
        )
    }
}

extension WatchWorkoutStep {
    init(step: TimedStep) {
        let style: WatchWorkoutStepStyle
        if step.accent == .work {
            style = .work
        } else if step.accent == .rest {
            style = .rest
        } else if step.accent == .walk {
            style = .walk
        } else {
            style = .info
        }

        self.init(
            id: step.id,
            title: step.title,
            detail: step.subtitle,
            durationSeconds: step.seconds,
            style: style
        )
    }

    init(phase: RunningPhase) {
        let style: WatchWorkoutStepStyle
        if phase.kind == .ritmoAlto || phase.kind == .ritmoMedio {
            style = .work
        } else if phase.kind == .ritmoSuave {
            style = .rest
        } else if phase.kind == .caminar {
            style = .walk
        } else {
            style = .info
        }

        self.init(
            id: phase.id,
            title: phase.kind.displayName,
            detail: phase.note,
            durationSeconds: phase.seconds,
            distanceMeters: phase.meters,
            style: style
        )
    }
}
