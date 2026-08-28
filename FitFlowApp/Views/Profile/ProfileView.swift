import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var profile: SupabaseService.UserProfile?
    @State private var username = ""
    @State private var fullName = ""
    @State private var gender: Gender = .notSpecified
    @State private var birthdate = Date()
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var isUploadingImage = false
    @State private var showSaveConfirmation = false
    @State private var errorMessage: String?
    @State private var hasChanges = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var avatarUrlChanged = false

    enum Gender: String, CaseIterable, Identifiable {
        case hombre = "Hombre"
        case mujer = "Mujer"
        case notSpecified = "Prefiero no decir"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    formView
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if hasChanges {
                        Button("Guardar") {
                            Task { await save() }
                        }
                        .disabled(isSaving)
                    }
                }
            }
            .alert("Perfil actualizado", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) {}
            }
        }
        .task { await loadProfile() }
    }

    private var formView: some View {
        Form {
            Section {
                VStack(spacing: 14) {
                    ZStack(alignment: .bottomTrailing) {
                        if let avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0, green: 0.85, blue: 0.65),
                                                Color(red: 0, green: 0.6, blue: 0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2.5
                                    )
                                )
                        } else if let avatarUrl = profile?.avatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    placeholderAvatar
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                @unknown default:
                                    placeholderAvatar
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0, green: 0.85, blue: 0.65),
                                            Color(red: 0, green: 0.6, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                            )
                        } else {
                            placeholderAvatar
                        }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 32, height: 32)
                                if isUploadingImage {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .offset(x: -4, y: -4)
                    }

                    if let email = profile?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let username = profile?.username, !username.isEmpty {
                        Text("@\(username)")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color(.systemBackground))
            }

            Section("Información personal") {
                HStack {
                    Image(systemName: "at")
                        .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                        .frame(width: 24)
                    TextField("Nombre de usuario", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: username) { checkChanges() }
                }

                HStack {
                    Image(systemName: "person")
                        .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                        .frame(width: 24)
                    TextField("Nombre completo", text: $fullName)
                        .textContentType(.name)
                        .onChange(of: fullName) { checkChanges() }
                }

                HStack {
                    Image(systemName: "person.2")
                        .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                        .frame(width: 24)
                    Picker("Género", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .onChange(of: gender) { checkChanges() }
                }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color(red: 0, green: 0.8, blue: 0.6))
                        .frame(width: 24)
                    DatePicker("Fecha de nacimiento", selection: $birthdate, displayedComponents: .date)
                        .onChange(of: birthdate) { checkChanges() }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button("Cerrar sesión", role: .destructive) {
                    Task {
                        try? await SupabaseService.shared.signOut()
                        appState.refreshFromSupabase()
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { newItem in
            Task { await loadSelectedPhoto(newItem) }
        }
    }

    private var placeholderAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 100))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0, green: 0.8, blue: 0.6),
                        Color(red: 0, green: 0.6, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 100, height: 100)
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isUploadingImage = true
        defer { isUploadingImage = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        avatarImage = image

        do {
            if let url = try await SupabaseService.shared.uploadAvatar(image: image) {
                if var p = profile {
                    p.avatarUrl = url
                    try await SupabaseService.shared.updateProfile(p)
                    profile = p
                }
            }
        } catch {
            errorMessage = "Error al subir imagen: \(error.localizedDescription)"
        }
    }

    private func loadProfile() async {
        isLoading = true
        do {
            if let p = try await SupabaseService.shared.fetchProfile() {
                profile = p
                username = p.username
                fullName = p.fullName
                if let g = p.gender {
                    gender = Gender(rawValue: g) ?? .notSpecified
                }
                if let bd = p.birthdate, let d = ISO8601DateFormatter().date(from: bd) {
                    birthdate = d
                }
                if let avatarUrl = p.avatarUrl, let url = URL(string: avatarUrl) {
                    await downloadAvatar(from: url)
                }
            } else {
                // Profile doesn't exist yet — create a placeholder
                try await createInitialProfile()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func createInitialProfile() async throws {
        guard let userId = SupabaseService.shared.currentUserID,
              let email = SupabaseService.shared.currentUserEmail else { return }

        let placeholder = SupabaseService.UserProfile(
            id: userId,
            username: email.components(separatedBy: "@").first ?? "user",
            fullName: "",
            gender: nil,
            birthdate: nil,
            email: email,
            avatarUrl: nil
        )

        try await SupabaseService.shared.updateProfile(placeholder)
        profile = placeholder
        username = placeholder.username
    }

    private func downloadAvatar(from url: URL) async {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return }
        avatarImage = image
    }

    private func checkChanges() {
        guard let p = profile else { return }
        hasChanges = username != p.username ||
                     fullName != p.fullName ||
                     gender.rawValue != (p.gender ?? "Prefiero no decir")
    }

    private func save() async {
        guard let existing = profile else { return }
        isSaving = true
        errorMessage = nil

        var updated = existing
        updated.username = username
        updated.fullName = fullName
        updated.gender = gender == .notSpecified ? nil : gender.rawValue

        let formatter = ISO8601DateFormatter()
        updated.birthdate = formatter.string(from: birthdate)

        do {
            try await SupabaseService.shared.updateProfile(updated)
            profile = updated
            hasChanges = false
            showSaveConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
