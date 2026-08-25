import SwiftUI

struct RunningWorkoutPickerView: View {
    @State private var customNotation: String = ""
    @State private var showCustomPlayer = false
    @State private var selectedSession: RunningSession?

    var body: some View {
        NavigationStack {
            List {
                Section("Notación personalizada") {
                    TextField("p.ej. 5´RM + 4 x (1´ RA + 1´30\"RS) + 8´ RM", text: $customNotation, axis: .vertical)
                        .lineLimit(1...3)
                    if !customNotation.isEmpty {
                        let preview = RunningNotationParser.parse(customNotation)
                        ForEach(preview) { phase in
                            HStack {
                                Circle().fill(PhaseColor.color(for: phase.kind)).frame(width: 8, height: 8)
                                Text(phase.kind.shortLabel)
                                Spacer()
                                if let s = phase.seconds {
                                    Text(formatted(s)).foregroundStyle(.secondary)
                                } else if let m = phase.meters {
                                    Text("\(m) m").foregroundStyle(.secondary)
                                } else {
                                    Text(phase.note ?? "manual").foregroundStyle(.secondary)
                                }
                            }.font(.footnote)
                        }
                        Button {
                            selectedSession = RunningSession(title: "Personalizado", rawNotation: customNotation, phases: preview)
                            showCustomPlayer = true
                        } label: {
                            Label("Empezar este entreno", systemImage: "play.fill")
                        }
                    }
                }

                ForEach(RunningWorkoutLibrary.blocks) { block in
                    Section(block.name) {
                        ForEach(block.days) { day in
                            Button {
                                selectedSession = day.makeSession(blockName: block.name)
                                showCustomPlayer = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(day.label).font(.headline)
                                    Text(day.notation)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Carrera")
            .navigationDestination(isPresented: $showCustomPlayer) {
                if let session = selectedSession {
                    RunningWorkoutPlayerView(session: session)
                }
            }
        }
    }

    private func formatted(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
