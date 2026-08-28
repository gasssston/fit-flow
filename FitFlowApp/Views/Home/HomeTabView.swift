import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentExerciseIndex = 0
    @State private var animateGradient = false
    @State private var showContent = false
    @State private var stats = HomeStats()
    @State private var isLoadingStats = true
    @State private var statsError: String?

    private let motivationalPhrases = [
        "Transforma tu cuerpo",
        "Supera tus límites",
        "Constante vence",
        "El dolor es temporal",
        "Sin excusas"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        animateGradient ? .blue.opacity(0.15) : .purple.opacity(0.15),
                        animateGradient ? .purple.opacity(0.1) : .blue.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

                ScrollView {
                    VStack(spacing: DS.Spacing.xl) {
                        headerSection
                        featuredWorkoutCard
                        quickStatsSection
                        motivationalSection
                    }
                    .padding(.horizontal)
                }
                .refreshable { await loadStats() }
            }
            .navigationTitle("FitFlow")
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .task { await loadStats() }
            .alert("No se pudo cargar tu progreso", isPresented: Binding(
                get: { statsError != nil },
                set: { if !$0 { statsError = nil } }
            )) {
                Button("Reintentar") { Task { await loadStats() } }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text(statsError ?? "Comprueba tu conexión e inténtalo de nuevo.")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(greeting)
                .font(.title2.bold())
            Text("¿Qué vas a entrenar hoy?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fadeIn($showContent, delay: 0.1)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Buenos días ☀️"
        case 12..<18: return "Buenas tardes 🌤"
        default: return "Buenas noches 🌙"
        }
    }

    private var featuredWorkoutCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("Circuito de Abdominales")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }

            Text("7 minutos para activar tu core")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: DS.Spacing.md) {
                Label("7 min", systemImage: "clock")
                Label("20s / 10s", systemImage: "timer")
                Label("7 ejercicios", systemImage: "figure.strengthtraining.traditional")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            exerciseCarousel
        }
        .cardStyle()
        .fadeIn($showContent, delay: 0.2)
    }

    private var exerciseCarousel: some View {
        TabView(selection: $currentExerciseIndex) {
            ForEach(0..<AbExerciseLibrary.all.count, id: \.self) { index in
                let exercise = AbExerciseLibrary.all[index]
                HStack(spacing: DS.Spacing.md) {
                    StickmanView(
                        animation: StickmanPoseLibrary.animation(for: exercise.id),
                        strokeColor: .primary,
                        jointColor: .orange
                    )
                    .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                            .font(.subheadline.bold())
                        Text("\(exercise.defaultWorkSeconds)s trabajo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 80)
    }

    private var quickStatsSection: some View {
        HStack(spacing: DS.Spacing.md) {
            StatCard(icon: "flame.fill", title: "Racha", value: isLoadingStats ? "--" : "\(stats.streakDays) días", color: .orange)
            StatCard(icon: "figure.run", title: "Carreras", value: isLoadingStats ? "--" : "\(stats.runningWorkouts)", color: .blue)
            StatCard(icon: "clock.fill", title: "Tiempo", value: isLoadingStats ? "--" : stats.formattedTime, color: .green)
        }
        .fadeIn($showContent, delay: 0.3)
    }

    private var motivationalSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Motivación del día")
                .font(.headline)
            Text(motivationalPhrases[currentExerciseIndex % motivationalPhrases.count])
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .id(currentExerciseIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .fadeIn($showContent, delay: 0.4)
        .onAppear {
            startMotivationTimer()
        }
    }

    private func startMotivationTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.5)) {
                currentExerciseIndex = (currentExerciseIndex + 1) % AbExerciseLibrary.all.count
            }
        }
    }

    @MainActor
    private func loadStats() async {
        isLoadingStats = true
        defer { isLoadingStats = false }
        do {
            stats = try await SupabaseService.shared.fetchHomeStats()
            statsError = nil
        } catch {
            statsError = error.localizedDescription
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.lg)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}
