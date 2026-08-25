import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userEmail: String?

    func refreshFromSupabase() {
        // Called on launch and after auth actions. The Supabase SDK exposes
        // an async auth-state-change stream; wire it up here once the
        // package is added in Xcode, e.g.:
        //
        // for await state in SupabaseService.shared.client.auth.authStateChanges {
        //     isAuthenticated = state.session != nil
        //     userEmail = state.session?.user.email
        // }
        isAuthenticated = SupabaseService.shared.currentUserID != nil
    }
}
