import Foundation

enum WatchWorkoutKind: String, Codable, Hashable, Sendable {
    case abs
    case running
}

enum WatchWorkoutStepStyle: String, Codable, Hashable, Sendable {
    case work
    case rest
    case walk
    case info
}

struct WatchWorkoutStep: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let title: String
    let detail: String?
    let durationSeconds: Int?
    let distanceMeters: Int?
    let style: WatchWorkoutStepStyle

    init(
        id: UUID = UUID(),
        title: String,
        detail: String? = nil,
        durationSeconds: Int? = nil,
        distanceMeters: Int? = nil,
        style: WatchWorkoutStepStyle
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.style = style
    }
}

struct WatchWorkoutPlan: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let kind: WatchWorkoutKind
    let steps: [WatchWorkoutStep]
    let sourceNotation: String?
}

struct WatchWorkoutCatalog: Codable, Equatable, Sendable {
    static let schemaVersion = 1

    let schemaVersion: Int
    let updatedAt: Date
    let plans: [WatchWorkoutPlan]

    init(updatedAt: Date = Date(), plans: [WatchWorkoutPlan]) {
        schemaVersion = Self.schemaVersion
        self.updatedAt = updatedAt
        self.plans = plans
    }
}

struct WatchWorkoutResult: Identifiable, Codable, Equatable, Sendable {
    static let schemaVersion = 1

    let schemaVersion: Int
    let id: UUID
    let planID: UUID
    let title: String
    let kind: WatchWorkoutKind
    let startedAt: Date
    let completedAt: Date
    let activeDurationSeconds: Int
    let sourceNotation: String?

    init(
        id: UUID = UUID(),
        planID: UUID,
        title: String,
        kind: WatchWorkoutKind,
        startedAt: Date,
        completedAt: Date = Date(),
        activeDurationSeconds: Int,
        sourceNotation: String?
    ) {
        schemaVersion = Self.schemaVersion
        self.id = id
        self.planID = planID
        self.title = title
        self.kind = kind
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.activeDurationSeconds = activeDurationSeconds
        self.sourceNotation = sourceNotation
    }
}

struct WatchWorkoutLiveState: Identifiable, Codable, Equatable, Sendable {
    static let schemaVersion = 1

    let schemaVersion: Int
    let id: UUID
    let plan: WatchWorkoutPlan
    let currentStepIndex: Int
    let remainingSeconds: TimeInterval
    let elapsedSeconds: TimeInterval
    let isRunning: Bool
    let isFinished: Bool
    let isPreparing: Bool
    let updatedAt: Date

    init(
        id: UUID,
        plan: WatchWorkoutPlan,
        currentStepIndex: Int,
        remainingSeconds: TimeInterval,
        elapsedSeconds: TimeInterval,
        isRunning: Bool,
        isFinished: Bool,
        isPreparing: Bool = false,
        updatedAt: Date = Date()
    ) {
        schemaVersion = Self.schemaVersion
        self.id = id
        self.plan = plan
        self.currentStepIndex = currentStepIndex
        self.remainingSeconds = remainingSeconds
        self.elapsedSeconds = elapsedSeconds
        self.isRunning = isRunning
        self.isFinished = isFinished
        self.isPreparing = isPreparing
        self.updatedAt = updatedAt
    }
}

struct WatchWorkoutLiveEnvelope: Codable, Sendable {
    let state: WatchWorkoutLiveState?
}

struct WatchWorkoutCommand: Codable, Sendable {
    enum Action: String, Codable, Sendable {
        case toggle
        case skip
    }

    let sessionID: UUID
    let action: Action
}

enum WatchSyncKey {
    nonisolated static let catalog = "workoutCatalog"
    nonisolated static let result = "workoutResult"
    nonisolated static let liveState = "liveWorkoutState"
    nonisolated static let command = "workoutCommand"
}
