import Foundation
import Supabase
import SwiftUI

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://rtqvpcvefligimqzgetn.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0cXZwY3ZlZmxpZ2ltcXpnZXRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1OTU2MzQsImV4cCI6MjEwMzE3MTYzNH0.EguqBJx8qvD-N_WmVnIM-Y39-k1P3mMQdFgbaamfX6E",
            options: SupabaseClientOptions(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }

    var currentUserID: UUID? {
        client.auth.currentSession?.user.id
    }

    var currentUserEmail: String? {
        client.auth.currentSession?.user.email
    }

    // MARK: - Auth

    func signUp(email: String, password: String, username: String, fullName: String, gender: String?, birthdate: Date) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        let userId = response.user.id

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let profile = UserProfile(
            id: userId,
            username: username,
            fullName: fullName,
            gender: gender,
            birthdate: formatter.string(from: birthdate),
            email: email,
            avatarUrl: nil
        )

        try await client
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Profile

    struct UserProfile: Codable, Equatable, Sendable {
        let id: UUID
        var username: String
        var fullName: String
        var gender: String?
        var birthdate: String?
        var email: String?
        var avatarUrl: String?

        enum CodingKeys: String, CodingKey {
            case id, username, gender, birthdate, email
            case fullName = "full_name"
            case avatarUrl = "avatar_url"
        }
    }

    func fetchProfile() async throws -> UserProfile? {
        guard let userId = currentUserID else { return nil }
        let response: [UserProfile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        return response.first
    }

    func updateProfile(_ profile: UserProfile) async throws {
        try await client
            .from("profiles")
            .upsert(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    // MARK: - Avatar Upload

    func uploadAvatar(image: UIImage) async throws -> String? {
        guard let userId = currentUserID,
              let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }

        let filePath = "avatars/\(userId.uuidString).jpg"

        try await client
            .storage
            .from("avatars")
            .upload(
                path: filePath,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )

        let url = try client
            .storage
            .from("avatars")
            .getPublicURL(path: filePath)

        return url.absoluteString
    }

    // MARK: - Abs Plannings

    func fetchPlannings() async throws -> [AbsPlanning] {
        guard let userId = currentUserID else { return [] }
        let response: [AbsPlanning] = try await client
            .from("abs_plannings")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    func savePlanning(_ planning: AbsPlanning) async throws {
        guard let userId = currentUserID else { return }
        var toSave = planning
        toSave.userId = userId
        try await client
            .from("abs_plannings")
            .upsert(toSave)
            .execute()
    }

    func deletePlanning(id: UUID) async throws {
        guard let userId = currentUserID else { return }
        try await client
            .from("abs_plannings")
            .delete()
            .eq("id", value: id.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Workout Progress

    private struct AbWorkoutLogInsert: Encodable {
        let userId: UUID
        let exercises: [String]
        let workSeconds: Int
        let restSeconds: Int
        let rounds: Int
        let durationSeconds: Int

        enum CodingKeys: String, CodingKey {
            case exercises, rounds
            case userId = "user_id"
            case workSeconds = "work_seconds"
            case restSeconds = "rest_seconds"
            case durationSeconds = "duration_seconds"
        }
    }

    private struct RunningWorkoutLogInsert: Encodable {
        let userId: UUID
        let title: String
        let rawNotation: String
        let durationSeconds: Int

        enum CodingKeys: String, CodingKey {
            case title
            case userId = "user_id"
            case rawNotation = "raw_notation"
            case durationSeconds = "duration_seconds"
        }
    }

    func saveAbWorkout(configuration: AbWorkoutConfiguration, durationSeconds: Int) async throws {
        guard let userId = currentUserID else { return }
        let log = AbWorkoutLogInsert(
            userId: userId,
            exercises: configuration.exerciseIds,
            workSeconds: configuration.workSeconds,
            restSeconds: configuration.restSeconds,
            rounds: configuration.rounds,
            durationSeconds: durationSeconds
        )
        try await client.from("ab_workout_logs").insert(log).execute()
    }

    func saveRunningWorkout(session: RunningSession, durationSeconds: Int) async throws {
        guard let userId = currentUserID else { return }
        let log = RunningWorkoutLogInsert(
            userId: userId,
            title: session.title,
            rawNotation: session.rawNotation,
            durationSeconds: durationSeconds
        )
        try await client.from("running_workout_logs").insert(log).execute()
    }

    func fetchHomeStats(calendar: Calendar = .current, now: Date = Date()) async throws -> HomeStats {
        guard let userId = currentUserID else { return HomeStats() }
        async let abLogs: [WorkoutLogSummary] = client
            .from("ab_workout_logs")
            .select("completed_at,duration_seconds")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        async let runningLogs: [WorkoutLogSummary] = client
            .from("running_workout_logs")
            .select("completed_at,duration_seconds")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        let (abs, runs) = try await (abLogs, runningLogs)
        let allLogs = abs + runs
        return HomeStats(
            streakDays: Self.streakDays(for: allLogs.map(\.completedAt), calendar: calendar, now: now),
            runningWorkouts: runs.count,
            totalSeconds: allLogs.reduce(0) { $0 + $1.durationSeconds }
        )
    }

    private static func streakDays(for dates: [Date], calendar: Calendar, now: Date) -> Int {
        let workoutDays = Set(dates.map { calendar.startOfDay(for: $0) })
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        var day = workoutDays.contains(today) ? today : yesterday
        var streak = 0

        while workoutDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        return streak
    }
}
