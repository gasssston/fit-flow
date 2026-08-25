import SwiftUI

/// Central place for the "sporty" color language used across both timers —
/// tweak these to restyle the whole app in one spot.
enum PhaseColor {
    static func color(for kind: RunningPhaseKind) -> Color {
        switch kind {
        case .ritmoAlto: return .red
        case .ritmoMedio: return .orange
        case .ritmoSuave: return .green
        case .caminar: return .teal
        case .distancia: return .purple
        case .nota: return .blue
        case .cronometro: return .indigo
        }
    }

    static func color(for accent: TimedStep.StepAccent) -> Color {
        switch accent {
        case .work: return .red
        case .rest: return .green
        case .walk: return .teal
        case .info: return .blue
        }
    }
}
