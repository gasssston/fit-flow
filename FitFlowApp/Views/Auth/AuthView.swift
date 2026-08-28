import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var fullName = ""
    @State private var gender: Gender = .notSpecified
    @State private var birthdate = Date()
    @State private var isSigningUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    // animations
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var particleOffset: [CGFloat] = Array(repeating: 0, count: 12)
    @State private var particleOpacity: [Double] = Array(repeating: 0, count: 12)
    @State private var particleX: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: -1...1) }
    @State private var particleY: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: 0.2...0.9) }
    @State private var particleSize: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: 2...5) }

    enum Gender: String, CaseIterable, Identifiable {
        case hombre = "Hombre"
        case mujer = "Mujer"
        case notSpecified = "Prefiero no decir"
        var id: String { rawValue }
    }

    private var isEmailValid: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private var isFormValid: Bool {
        guard isEmailValid, password.count >= 6 else { return false }
        if isSigningUp {
            return !username.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   password == confirmPassword
        }
        return true
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.07, blue: 0.09)
                .ignoresSafeArea()

            // Radial glow
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0, green: 0.6, blue: 0.45).opacity(0.25),
                    Color(red: 0, green: 0.4, blue: 0.3).opacity(0.08),
                    .clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: glowRadius
            )
            .ignoresSafeArea()

            // Particles
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0, green: 0.85, blue: 0.65),
                                Color(red: 0, green: 0.6, blue: 0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: particleSize[i], height: particleSize[i])
                    .position(
                        x: UIScreen.main.bounds.width * (0.5 + particleX[i] * 0.45),
                        y: UIScreen.main.bounds.height * particleY[i]
                    )
                    .offset(y: particleOffset[i])
                    .opacity(particleOpacity[i])
                    .blur(radius: particleSize[i] > 3.5 ? 1 : 0)
            }

            // Content
            VStack(spacing: 12) {
                    Spacer(minLength: 16)
                    // Logo
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(red: 0, green: 0.8, blue: 0.6).opacity(0.4), radius: 12, y: 4)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0, green: 0.85, blue: 0.65).opacity(0.7),
                                            Color(red: 0, green: 0.7, blue: 0.5).opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .opacity(logoOpacity * 0.5)
                        )

                    // Title
                    Text("FitFlow")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0, green: 0.9, blue: 0.7),
                                    Color(red: 0.2, green: 0.8, blue: 0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(contentOpacity)

                    Text(isSigningUp ? "Crea tu cuenta" : "Bienvenido de vuelta")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .opacity(contentOpacity)

                    // Form
                    VStack(spacing: 8) {
                        // Email
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 18)
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                        .padding(10)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(email.isEmpty ? .clear : (isEmailValid ? Color(red: 0, green: 0.8, blue: 0.6).opacity(0.5) : .red.opacity(0.5)), lineWidth: 1)
                        )

                        if !email.isEmpty && !isEmailValid {
                            Text("Email no válido")
                                .font(.caption2)
                                .foregroundStyle(.red.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 4)
                        }

                        // Password
                        HStack(spacing: 8) {
                            Image(systemName: "lock")
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 18)
                            if showPassword {
                                TextField("Contraseña", text: $password)
                                    .textContentType(isSigningUp ? .newPassword : .password)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            } else {
                                SecureField("Contraseña", text: $password)
                                    .textContentType(isSigningUp ? .newPassword : .password)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(.white.opacity(0.4))
                                    .font(.caption)
                            }
                        }
                        .padding(10)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                        if isSigningUp {
                            // Confirm password
                            HStack(spacing: 8) {
                                Image(systemName: "lock.rotation")
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(width: 18)
                                if showConfirmPassword {
                                    TextField("Confirmar contraseña", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                } else {
                                    SecureField("Confirmar contraseña", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                Button {
                                    showConfirmPassword.toggle()
                                } label: {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.white.opacity(0.4))
                                        .font(.caption)
                                }
                            }
                            .padding(10)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(!confirmPassword.isEmpty && password != confirmPassword ? .red.opacity(0.5) : .clear, lineWidth: 1)
                            )

                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Las contraseñas no coinciden")
                                    .font(.caption2)
                                    .foregroundStyle(.red.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 4)
                            }

                            // Username
                            HStack(spacing: 8) {
                                Image(systemName: "at")
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(width: 18)
                                TextField("Nombre de usuario", text: $username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                            .padding(10)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                            // Full name
                            HStack(spacing: 8) {
                                Image(systemName: "person")
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(width: 18)
                                TextField("Nombre completo", text: $fullName)
                                    .textContentType(.name)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                            .padding(10)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                            // Gender + Birthdate row
                            HStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.2")
                                        .foregroundStyle(.white.opacity(0.4))
                                        .frame(width: 18)
                                    Picker("Género", selection: $gender) {
                                        ForEach(Gender.allCases) { g in
                                            Text(g.rawValue).tag(g)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.white)
                                    .font(.subheadline)
                                }
                                .padding(10)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.white.opacity(0.4))
                                    DatePicker("Nacimiento", selection: $birthdate, displayedComponents: .date)
                                        .labelsHidden()
                                        .foregroundStyle(.white)
                                        .tint(Color(red: 0, green: 0.8, blue: 0.6))
                                }
                                .padding(10)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .opacity(contentOpacity)

                    // Error
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Submit button
                    Button {
                        Task { await submit() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isSigningUp ? "Crear cuenta" : "Entrar")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0, green: 0.7, blue: 0.5),
                                Color(red: 0, green: 0.55, blue: 0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color(red: 0, green: 0.7, blue: 0.5).opacity(0.3), radius: 8, y: 3)
                    .disabled(!isFormValid || isLoading)
                    .opacity(contentOpacity)

                    // Toggle auth mode
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            isSigningUp.toggle()
                            errorMessage = nil
                        }
                    } label: {
                        Text(isSigningUp ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                    }
                    .opacity(contentOpacity)
                    Spacer()
                }
                .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.15)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
            glowRadius = 260
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            contentOpacity = 1.0
        }
        for i in 0..<12 {
            let delay = Double.random(in: 0.6...1.4)
            let duration = Double.random(in: 2.0...4.0)
            withAnimation(
                .easeInOut(duration: duration)
                .delay(delay)
                .repeatForever(autoreverses: true)
            ) {
                particleOffset[i] = CGFloat.random(in: -60...(-25))
                particleOpacity[i] = Double.random(in: 0.15...0.5)
            }
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSigningUp {
                try await SupabaseService.shared.signUp(
                    email: email,
                    password: password,
                    username: username.trimmingCharacters(in: .whitespaces),
                    fullName: fullName.trimmingCharacters(in: .whitespaces),
                    gender: gender == .notSpecified ? nil : gender.rawValue,
                    birthdate: birthdate
                )
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
