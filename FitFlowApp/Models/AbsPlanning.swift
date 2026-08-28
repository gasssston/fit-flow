import Foundation

/// A saved abdominal circuit: a named group of exercises with custom
/// work/rest durations and round count.
struct AbsPlanning: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var userId: UUID?
    var name: String
    var exerciseIds: [String]
    var workSeconds: Int
    var restSeconds: Int
    var rounds: Int

    enum CodingKeys: String, CodingKey {
        case id, name, rounds
        case userId = "user_id"
        case exerciseIds = "exercise_ids"
        case workSeconds = "work_seconds"
        case restSeconds = "rest_seconds"
    }

    /// Resolves exercise IDs to full `AbExercise` objects from the library.
    var exercises: [AbExercise] {
        exerciseIds.compactMap { id in
            AbExerciseLibrary.all.first { $0.id == id }
        }
    }

    /// Builds the `[TimedStep]` array ready for `IntervalTimerEngine`.
    var steps: [TimedStep] {
        let exercises = self.exercises
        guard !exercises.isEmpty else { return [] }
        var steps: [TimedStep] = []
        for _ in 0..<rounds {
            for (index, exercise) in exercises.enumerated() {
                steps.append(TimedStep(
                    title: exercise.name,
                    subtitle: exercise.id,
                    seconds: workSeconds,
                    accent: .work
                ))
                let nextExercise = index + 1 < exercises.count ? exercises[index + 1] : exercises.first
                let restTitle = nextExercise.map { "Descanso → \($0.name)" } ?? "Descanso"
                steps.append(TimedStep(
                    title: restTitle,
                    subtitle: nextExercise?.id,
                    seconds: restSeconds,
                    accent: .rest
                ))
            }
        }
        if steps.last?.accent == .rest { steps.removeLast() }
        return steps
    }
}
