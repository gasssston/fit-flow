import SwiftUI

/// A big circular countdown ring with a pulsing "power" glow while running —
/// the main visual focus of both timer screens.
struct RingProgressView: View {
    let progress: Double     // 0...1
    let accentColor: Color
    let isRunning: Bool
    let centerText: String
    let centerSubtext: String

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: 18)

            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(accentColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)

            Circle()
                .stroke(accentColor.opacity(pulse ? 0.0 : 0.35), lineWidth: 4)
                .scaleEffect(pulse ? 1.12 : 1.0)
                .opacity(isRunning ? 1 : 0)
                .animation(.easeOut(duration: 1.1).repeatForever(autoreverses: false), value: pulse)

            VStack(spacing: 6) {
                Text(centerText)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(centerSubtext)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.45)
                    .allowsTightening(true)
                    .frame(width: 150, height: 54)
            }
        }
        .padding(24)
        .aspectRatio(1, contentMode: .fit)
        .onAppear { pulse = true }
    }
}
