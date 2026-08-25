import Foundation

/// A single core/abs exercise: a name, a stickman animation id, and default
/// work/rest durations (defaults match the 20s work / 10s rest pattern from
/// the reference video, but are editable per-session in the UI).
struct AbExercise: Identifiable, Codable, Equatable {
    let id: String              // matches a StickmanAnimation.id
    let name: String
    var defaultWorkSeconds: Int = 20
    var defaultRestSeconds: Int = 10
}

enum AbExerciseLibrary {
    static let all: [AbExercise] = [
        AbExercise(id: "plank", name: "Plancha prona"),
        AbExercise(id: "sidePlankLeft", name: "Plancha lateral (apoyo izquierdo)"),
        AbExercise(id: "sidePlankRight", name: "Plancha lateral (apoyo derecho)"),
        AbExercise(id: "commandoPlank", name: "Commando plank"),
        AbExercise(id: "mountainClimbers", name: "Escaladores"),
        AbExercise(id: "legRaise", name: "Elevación de piernas"),
        AbExercise(id: "crunch", name: "Crunch"),
    ]

    /// Builds a default circuit: every exercise once, work/rest intervals,
    /// matching the "20s trabajo + 10s descanso" pattern.
    static func defaultCircuit() -> [AbExercise] { all }
}
