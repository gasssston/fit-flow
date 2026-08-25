import Foundation
import Supabase   // Swift Package: https://github.com/supabase/supabase-swift

/// Thin wrapper around the Supabase Swift SDK for auth. Add your project's
/// URL and anon key below (or load them from a local, git-ignored .plist —
/// see the README).
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

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
