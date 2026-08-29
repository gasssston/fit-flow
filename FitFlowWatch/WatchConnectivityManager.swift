import Combine
import Foundation
import WatchConnectivity

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    @Published private(set) var plans: [WatchWorkoutPlan] = []
    @Published private(set) var isPhoneReachable = false
    @Published private(set) var liveState: WatchWorkoutLiveState?

    private let catalogDefaultsKey = "cachedWorkoutCatalog"
    private let ignoredLiveSessionDefaultsKey = "ignoredLiveWorkoutSession"
    private let session: WCSession?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    override init() {
        session = WCSession.isSupported() ? .default : nil
        super.init()
        restoreCatalog()
        session?.delegate = self
        session?.activate()
    }

    func send(_ result: WatchWorkoutResult) {
        guard let session else { return }
        do {
            let data = try encoder.encode(result)
            session.transferUserInfo([WatchSyncKey.result: data])
        } catch {
            print("Failed to queue workout result: \(error)")
        }
    }

    func send(_ action: WatchWorkoutCommand.Action, sessionID: UUID) {
        guard let session, session.isReachable else { return }
        do {
            let command = WatchWorkoutCommand(sessionID: sessionID, action: action)
            let data = try encoder.encode(command)
            session.sendMessage([WatchSyncKey.command: data], replyHandler: nil) { error in
                print("Failed to send workout command: \(error)")
            }
        } catch {
            print("Failed to encode workout command: \(error)")
        }
    }

    func dismissLiveSession() {
        guard let sessionID = liveState?.id else { return }
        UserDefaults.standard.set(sessionID.uuidString, forKey: ignoredLiveSessionDefaultsKey)
        liveState = nil
    }

    private func receive(catalogData: Data) {
        do {
            let catalog = try decoder.decode(WatchWorkoutCatalog.self, from: catalogData)
            guard catalog.schemaVersion == WatchWorkoutCatalog.schemaVersion else { return }
            plans = catalog.plans
            UserDefaults.standard.set(catalogData, forKey: catalogDefaultsKey)
        } catch {
            print("Failed to decode workout catalog: \(error)")
        }
    }

    private func restoreCatalog() {
        guard let data = UserDefaults.standard.data(forKey: catalogDefaultsKey) else { return }
        receive(catalogData: data)
    }

    private func receive(liveStateData: Data) {
        do {
            let envelope = try decoder.decode(WatchWorkoutLiveEnvelope.self, from: liveStateData)
            guard let incoming = envelope.state else {
                UserDefaults.standard.removeObject(forKey: ignoredLiveSessionDefaultsKey)
                liveState = nil
                return
            }
            if UserDefaults.standard.string(forKey: ignoredLiveSessionDefaultsKey) == incoming.id.uuidString {
                return
            }
            UserDefaults.standard.removeObject(forKey: ignoredLiveSessionDefaultsKey)
            if let current = liveState,
               incoming.id == current.id,
               incoming.updatedAt < current.updatedAt {
                return
            }
            liveState = incoming
        } catch {
            print("Failed to decode active workout: \(error)")
        }
    }

    private func receive(context: [String: Any]) {
        if let data = context[WatchSyncKey.catalog] as? Data {
            receive(catalogData: data)
        }
        if let data = context[WatchSyncKey.liveState] as? Data {
            receive(liveStateData: data)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        Task { @MainActor in
            self.isPhoneReachable = session.isReachable
            self.receive(context: session.receivedApplicationContext)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in self.isPhoneReachable = session.isReachable }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.receive(context: applicationContext) }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message[WatchSyncKey.liveState] as? Data else { return }
        Task { @MainActor in self.receive(liveStateData: data) }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard let data = message[WatchSyncKey.liveState] as? Data else {
            replyHandler([:])
            return
        }
        Task { @MainActor in
            self.receive(liveStateData: data)
            replyHandler([:])
        }
    }
}
