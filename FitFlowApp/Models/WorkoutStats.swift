import Foundation

struct AbWorkoutConfiguration {
    let exerciseIds: [String]
    let workSeconds: Int
    let restSeconds: Int
    let rounds: Int
}

struct HomeStats {
    var streakDays = 0
    var runningWorkouts = 0
    var totalSeconds = 0

    var formattedTime: String {
        if totalSeconds < 60 {
            return "0 min"
        }
        if totalSeconds < 3_600 {
            return "\(totalSeconds / 60) min"
        }

        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        return minutes == 0 ? "\(hours) h" : "\(hours) h \(minutes) min"
    }
}

struct WorkoutLogSummary: Decodable {
    let completedAt: Date
    let durationSeconds: Int

    enum CodingKeys: String, CodingKey {
        case completedAt = "completed_at"
        case durationSeconds = "duration_seconds"
    }
}
