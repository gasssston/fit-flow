import Foundation

/// A single core/abs exercise: a name, a stickman animation id, and default
/// work/rest durations (defaults match the 20s work / 10s rest pattern from
/// the reference video, but are editable per-session in the UI).
struct AbExercise: Identifiable, Codable, Equatable {
    let id: String              // matches a StickmanAnimation.id
    let name: String
    var defaultWorkSeconds: Int = 10
    var defaultRestSeconds: Int = 10
}

enum AbExerciseLibrary {
    static let all: [AbExercise] = [
        AbExercise(id: "plank", name: "Plancha prona"),
        AbExercise(id: "plankKnees", name: "Plancha con rodillas"),
        AbExercise(id: "highPlank", name: "Plancha alta"),
        AbExercise(id: "sidePlankLeft", name: "Plancha lateral (apoyo izquierdo)"),
        AbExercise(id: "sidePlankRight", name: "Plancha lateral (apoyo derecho)"),
        AbExercise(id: "commandoPlank", name: "Commando plank"),
        AbExercise(id: "plankLegRaise", name: "Plancha con elevación de piernas"),
        AbExercise(id: "spidermanPlank", name: "Plancha spiderman"),
        AbExercise(id: "supermanPlank", name: "Plancha superman"),
        AbExercise(id: "mountainClimbers", name: "Escaladores"),
        AbExercise(id: "legRaise", name: "Elevación de piernas"),
        AbExercise(id: "jackknife", name: "Navaja abdominal (jackknife)"),
        AbExercise(id: "legCircles", name: "Círculos de pierna (leg circles)"),
        AbExercise(id: "legRaiseAlternating", name: "Elevación de piernas alternada"),
        AbExercise(id: "alternatingKneeTucks", name: "Rodilla al pecho alternada"),
        AbExercise(id: "legScissors", name: "Tijera de piernas"),
        AbExercise(id: "windshieldWipers", name: "Windshield wipers (limpiaparabrisas)"),
        AbExercise(id: "crunch", name: "Crunch"),
        AbExercise(id: "bicycleCrunch", name: "Bicycle crunch"),
        AbExercise(id: "heelTouches", name: "Toques de talón"),
        AbExercise(id: "vTwist", name: "V-twist (Russian twist)"),
        AbExercise(id: "hollowHold", name: "Hollow body hold (V-sit isométrico)"),
        AbExercise(id: "flatExtendedHold", name: "Extensión total isométrica"),
        AbExercise(id: "vUp", name: "V-up completo"),
        AbExercise(id: "supportedKneeTuck", name: "Tuck crunch apoyado"),
        AbExercise(id: "butterflySitUp", name: "Sit-up en diamante (butterfly)"),
        AbExercise(id: "crossToeTouch", name: "Toe touch cruzado"),
    ]

    /// Builds a default circuit: every exercise once, work/rest intervals,
    /// matching the "20s trabajo + 10s descanso" pattern.
    static func defaultCircuit() -> [AbExercise] { all }
}
