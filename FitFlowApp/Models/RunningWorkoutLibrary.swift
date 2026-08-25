import Foundation

/// Seed data extracted from the user's own training spreadsheet
/// (CARRERA 1 / 2 / 3 sheets, "Resumen" column). Only the running-only
/// blocks are included, as requested — strength (FUERZA) days are not.
enum RunningWorkoutLibrary {
    static let blocks: [RunningWorkoutBlock] = [
        RunningWorkoutBlock(name: "CARRERA 1", days: [
            RunningWorkoutDay(label: "DÍA 1", notation: "2 x [4 x (1´RM + 2´RS o caminado)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 2", notation: "5´RM + 4 x (30\" RA recup. 1´30\"´RS o caminado) + 10´ RM"),
            RunningWorkoutDay(label: "DÍA 3", notation: "6´ RM + 4 x (80m progresivos recup. 2’RS o caminando) + 10’ RM"),
            RunningWorkoutDay(label: "DÍA 4", notation: "2 x [3 x (1´30RM + 2´30\"RS o caminando)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 5", notation: "5´RM + 5 x (30\" RA recup 1´30\"´RS) + 10´ RM"),
            RunningWorkoutDay(label: "DÍA 6", notation: "6´ RM + 6 x (80m progresivos recup. 2’RS o caminando) + 10’ RM"),
            RunningWorkoutDay(label: "DÍA 7", notation: "2 x [5 x (1´RM + 2´RS o caminando)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 8", notation: "5´RM + 6 x (30\" RA recup. 1´30\"´RS o caminando) + 10´ RM"),
            RunningWorkoutDay(label: "DÍA 9", notation: "6´ RM + 8 x (80m progresivos recup. 2’RS o caminando) + 8’ RM"),
            RunningWorkoutDay(label: "DÍA 10", notation: "2 x [4 x (1´30RM + 2´30\"RS o caminando)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 11", notation: "6 x (45´´ RA recup. 2´RS o caminando)"),
            RunningWorkoutDay(label: "DÍA 12", notation: "DÍA AISLADO SIMULACRO + recup. 5´ caminando  + 15´ RM"),
        ]),
        RunningWorkoutBlock(name: "CARRERA 2", days: [
            RunningWorkoutDay(label: "DÍA 1", notation: "2 x [4 x (1´30\"RM + 2´RS o caminado)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 2", notation: "5´RM + 4 x (45\" RA recup. 2´RS o caminado) + 12´ RM"),
            RunningWorkoutDay(label: "DÍA 3", notation: "6´ RM + 4 x (100m progresivos recup. 2’RS o caminando) + 12’ RM"),
            RunningWorkoutDay(label: "DÍA 4", notation: "2 x [3 x (2´RM + 2´30\"RS o caminado)] recup. Entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 5", notation: "5´RM + 5 x (45\" RA recup. 2´RS o caminado) + 12´ RM"),
            RunningWorkoutDay(label: "DÍA 6", notation: "6´ RM + 6 x (100m progresivos recup. 2’RS o caminando) + 12’ RM"),
            RunningWorkoutDay(label: "DÍA 7", notation: "2x[5x(1´30\"RM + 2´RS o caminado)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 8", notation: "5´RM + 6 x (45\" RA recup. 2´RS o caminado) + 12´ RM"),
            RunningWorkoutDay(label: "DÍA 9", notation: "6´ RM + 8 x (100m progresivos recup. 2’RS o caminando) + 12’ RM"),
            RunningWorkoutDay(label: "DÍA 10", notation: "2 x [4 x (2´RM + 2´30\"RS o caminado)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 11", notation: "8 x (45´´ RA recup. 2´RS o caminando)"),
            RunningWorkoutDay(label: "DÍA 12", notation: "SIMULACRO + recup. 5´ caminando"),
        ]),
        RunningWorkoutBlock(name: "CARRERA 3", days: [
            RunningWorkoutDay(label: "DÍA 1", notation: "5´RM + 4 x (1´ RA + 1´30\"´RS) + 8´ RM"),
            RunningWorkoutDay(label: "DÍA 2", notation: "2 x (600m RA recup. 2’30\"RS o caminando) + recup. entre bloque 3´RS o caminando + 2 x (400m RA recup. 2´RS o caminando) + 6´ RM"),
            RunningWorkoutDay(label: "DÍA 3", notation: "2 x [3 x (30´´RA en cuesta recup. 1´30\"RS o caminando) + 4´RM)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 4", notation: "5´RM + 5 x (1´ RA + 1´30\"´RS) + 8´ RM"),
            RunningWorkoutDay(label: "DÍA 5", notation: "2 x (600m RA recup. 2’30\"RS o caminando) + recup. entre bloque 3´RS o caminando + 3 x (400m RA recup. 2´RS o caminando) + 6´ RM"),
            RunningWorkoutDay(label: "DÍA 6", notation: "2 x [4 x (30´´RA en cuesta recup. 1´30\"RS o caminando) + 4´RM)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 7", notation: "5´RM + 6 x (1´ RA + 1´30\"´RS) + 8´ RM"),
            RunningWorkoutDay(label: "DÍA 8", notation: "2 x (600m RA recup. 2’30\"RS o caminando) + recup. entre bloque 3´RS o caminando + 4 x (400m RA recup. 2´RS o caminando) + 6´ RM"),
            RunningWorkoutDay(label: "DÍA 9", notation: "2 x [5 x (30´´RA en cuesta recup. 1´30\"RS o caminando) + 4´RM)] recup. entre bloques 3´RS o caminando"),
            RunningWorkoutDay(label: "DÍA 10", notation: "5´RM + 7 x (1´ RA + 1´30\"´RS) + 8´ RM"),
            RunningWorkoutDay(label: "DÍA 11", notation: "6 x (1´ RA recup. 2´RS)"),
            RunningWorkoutDay(label: "DÍA 12", notation: "TEST DE COURSE NAVETTE + recup. 5´ caminando + 15´RS"),
        ]),
    ]
}

struct RunningWorkoutBlock: Identifiable {
    let id = UUID()
    let name: String
    let days: [RunningWorkoutDay]
}

struct RunningWorkoutDay: Identifiable {
    let id = UUID()
    let label: String
    let notation: String

    func makeSession(blockName: String) -> RunningSession {
        RunningSession(
            title: "\(blockName) · \(label)",
            rawNotation: notation,
            phases: RunningNotationParser.parse(notation)
        )
    }
}