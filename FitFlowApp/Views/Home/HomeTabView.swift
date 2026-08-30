import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentExerciseIndex = 0
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
                DS.Colors.canvas
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(DS.Colors.brandMid.opacity(0.16))
                            .frame(width: 280)
                            .blur(radius: 80)
                            .offset(x: 110, y: -90)
                    }
                .ignoresSafeArea()

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
            .toolbar(.hidden, for: .navigationBar)
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
            Text("FITFLOW / HOY")
                .font(.caption.bold())
                .tracking(2.4)
                .foregroundStyle(DS.Colors.brandMid)
            Text(greeting.uppercased())
                .font(.system(size: 40, weight: .black, design: .rounded))
                .minimumScaleFactor(0.75)
            Text("¿QUÉ VAS A ENTRENAR?")
                .font(.caption.weight(.semibold))
                .tracking(1.6)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fadeIn($showContent, delay: 0.1)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }

    private var featuredWorkoutCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("01")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(DS.Colors.brandMid)
                Text("CORE EXPRESS")
                    .font(.headline.weight(.black))
                    .tracking(0.8)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }

            Text("7 minutos para\nactivar tu core")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)

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
                    ExerciseVisualizerView(
                        animation: StickmanPoseLibrary.animation(for: exercise.id),
                        strokeColor: .primary,
                        jointColor: DS.Colors.brandMid
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
            StatCard(icon: "bolt.fill", title: "Racha", value: isLoadingStats ? "--" : "\(stats.streakDays) días", color: DS.Colors.brandMid)
            StatCard(icon: "figure.run", title: "Carreras", value: isLoadingStats ? "--" : "\(stats.runningWorkouts)", color: .white)
            StatCard(icon: "clock.fill", title: "Tiempo", value: isLoadingStats ? "--" : stats.formattedTime, color: DS.Colors.brandMid)
        }
        .fadeIn($showContent, delay: 0.3)
    }

    private var motivationalSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Motivación del día")
                .font(.caption.bold())
                .tracking(1.8)
                .foregroundStyle(DS.Colors.brandMid)
            Text(motivationalPhrases[currentExerciseIndex % motivationalPhrases.count])
                .font(.system(size: 28, weight: .black, design: .rounded))
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
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).stroke(DS.Colors.hairline))
    }
}
