import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text("FitFlow")
                    .font(.largeTitle.bold())

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Contraseña", text: $password)
                        .textContentType(isSigningUp ? .newPassword : .password)
                        .textFieldStyle(.roundedBorder)
                }

                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.red)
                }

                Button {
                    Task { await submit() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(isSigningUp ? "Crear cuenta" : "Entrar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .disabled(email.isEmpty || password.count < 6 || isLoading)

                Button(isSigningUp ? "Ya tengo cuenta" : "Crear una cuenta nueva") {
                    isSigningUp.toggle()
                }
                .font(.footnote)
            }
            .padding(32)
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSigningUp {
                try await SupabaseService.shared.signUp(email: email, password: password)
            } else {
                try await SupabaseService.shared.signIn(email: email, password: password)
            }
            appState.refreshFromSupabase()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
