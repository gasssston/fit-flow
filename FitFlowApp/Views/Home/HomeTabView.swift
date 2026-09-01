import SwiftUI

struct HomeTabView: View {
    @Binding var selectedTab: Int
    @State private var showContent = false
    @State private var stats = HomeStats()
    @State private var isLoadingStats = true
    @State private var statsError: String?

    private var runningSessionCount: Int {
        RunningWorkoutLibrary.blocks.reduce(0) { $0 + $1.days.count }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.canvas
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(DS.Colors.brandMid.opacity(0.14))
                            .frame(width: 300)
                            .blur(radius: 90)
                            .offset(x: 130, y: -100)
                    }
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Spacing.xxl) {
                        headerSection
                        trainingSection
                        progressSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, DS.Spacing.xxl)
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
        HStack(alignment: .top, spacing: DS.Spacing.lg) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("FITFLOW / HOY")
                    .font(.caption.bold())
                    .tracking(2.4)
                    .foregroundStyle(DS.Colors.brandMid)

                Text(greeting)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.75)

                Text("Elige cómo quieres moverte.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.sm)
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

    private var trainingSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            sectionTitle("Entrena hoy", subtitle: "Dos formas de avanzar, a tu ritmo")

            Button {
                selectedTab = 1
            } label: {
                WorkoutActionCard(
                    eyebrow: "FUERZA",
                    title: "Abdominales",
                    description: "Crea tu circuito, ajusta tiempos y guarda tus planes.",
                    detail: "\(AbExerciseLibrary.all.count) ejercicios",
                    icon: "figure.strengthtraining.traditional",
                    accent: DS.Colors.brandMid,
                    featured: true
                )
            }
            .buttonStyle(.plain)

            Button {
                selectedTab = 2
            } label: {
                WorkoutActionCard(
                    eyebrow: "RESISTENCIA",
                    title: "Carrera",
                    description: "Sigue una sesión o escribe tu propio entrenamiento.",
                    detail: "\(runningSessionCount) sesiones",
                    icon: "figure.run",
                    accent: .orange,
                    featured: false
                )
            }
            .buttonStyle(.plain)
        }
        .fadeIn($showContent, delay: 0.2)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            sectionTitle("Tu progreso", subtitle: "Cada entrenamiento cuenta")

            HStack(spacing: DS.Spacing.md) {
                StatCard(icon: "bolt.fill", title: "Racha", value: isLoadingStats ? "--" : "\(stats.streakDays) días", color: DS.Colors.brandMid)
                StatCard(icon: "figure.run", title: "Carreras", value: isLoadingStats ? "--" : "\(stats.runningWorkouts)", color: .orange)
                StatCard(icon: "clock.fill", title: "Tiempo", value: isLoadingStats ? "--" : stats.formattedTime, color: .white)
            }
        }
        .fadeIn($showContent, delay: 0.3)
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func loadStats() async {
        isLoadingStats = true
        defer { isLoadingStats = false }
        do {
            stats = try await SupabaseService.shared.fetchHomeStats()
            statsError = nil
        } catch is CancellationError {
            return
        } catch {
            statsError = error.localizedDescription
        }
    }
}

private struct WorkoutActionCard: View {
    let eyebrow: String
    let title: String
    let description: String
    let detail: String
    let icon: String
    let accent: Color
    let featured: Bool

    var body: some View {
        HStack(spacing: DS.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .fill(accent.opacity(0.14))
                Image(systemName: icon)
                    .font(.system(size: featured ? 34 : 28, weight: .medium))
                    .foregroundStyle(accent)
            }
            .frame(width: featured ? 82 : 68, height: featured ? 104 : 88)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(eyebrow)
                    .font(.caption2.bold())
                    .tracking(1.5)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.system(size: featured ? 25 : 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Label(detail, systemImage: "arrow.right")
                    .font(.caption.bold())
                    .foregroundStyle(accent)
            }

            Spacer(minLength: 0)
        }
        .padding(DS.Spacing.lg)
        .background(
            LinearGradient(
                colors: [accent.opacity(featured ? 0.13 : 0.07), DS.Colors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                .stroke(accent.opacity(featured ? 0.32 : 0.18))
        }
        .contentShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
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
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.lg)
        .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous).stroke(DS.Colors.hairline))
    }
}
