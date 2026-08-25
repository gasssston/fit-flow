import Foundation

/// The kind of effort a running phase represents.
enum RunningPhaseKind: String, Codable {
    case ritmoAlto     // RA - high tempo
    case ritmoMedio    // RM - medium tempo
    case ritmoSuave    // RS - easy / recovery
    case caminar       // walking recovery
    case distancia     // fixed-distance segment (no fixed duration)
    case nota          // instructional note, requires manual "start" tap
    case cronometro    // open stopwatch (e.g. course navette test)

    var shortLabel: String {
        switch self {
        case .ritmoAlto: return "RA"
        case .ritmoMedio: return "RM"
        case .ritmoSuave: return "RS"
        case .caminar: return "Caminar"
        case .distancia: return "Distancia"
        case .nota: return "Info"
        case .cronometro: return "Cronómetro"
        }
    }

    var displayName: String {
        switch self {
        case .ritmoAlto: return "Ritmo alto"
        case .ritmoMedio: return "Ritmo medio"
        case .ritmoSuave: return "Ritmo suave"
        case .caminar: return "Caminar"
        case .distancia: return "Tramo de distancia"
        case .nota: return "Prepárate"
        case .cronometro: return "Cronómetro libre"
        }
    }
}

/// A single, already-flattened phase in a running session — either time based
/// (`seconds`) or distance based (`meters`), or an open-ended note/stopwatch.
struct RunningPhase: Identifiable, Codable, Equatable {
    let id: UUID
    let kind: RunningPhaseKind
    var seconds: Int?      // nil for distance / note / stopwatch phases
    var meters: Int?       // set only for .distancia
    var note: String?      // free text, set for .nota

    init(kind: RunningPhaseKind, seconds: Int? = nil, meters: Int? = nil, note: String? = nil) {
        self.id = UUID()
        self.kind = kind
        self.seconds = seconds
        self.meters = meters
        self.note = note
    }

    var isTimed: Bool { seconds != nil }
}

/// A complete, ready-to-run session: an ordered list of phases plus metadata.
struct RunningSession: Identifiable, Codable {
    let id: UUID
    var title: String          // e.g. "Carrera 1 · Día 2"
    var rawNotation: String    // original text, kept for reference/editing
    var phases: [RunningPhase]

    init(title: String, rawNotation: String, phases: [RunningPhase]) {
        self.id = UUID()
        self.title = title
        self.rawNotation = rawNotation
        self.phases = phases
    }

    var totalTimedSeconds: Int {
        phases.compactMap(\.seconds).reduce(0, +)
    }
}
