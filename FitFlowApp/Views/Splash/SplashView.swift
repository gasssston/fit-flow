import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var particleOffset: [CGFloat] = Array(repeating: 0, count: 20)
    @State private var particleOpacity: [Double] = Array(repeating: 0, count: 20)
    @State private var particleX: [CGFloat] = (0..<20).map { _ in CGFloat.random(in: -1...1) }
    @State private var particleY: [CGFloat] = (0..<20).map { _ in CGFloat.random(in: 0.3...0.9) }
    @State private var particleSize: [CGFloat] = (0..<20).map { _ in CGFloat.random(in: 2...6) }
    @State private var phase: SplashPhase = .logoAppear

    @Binding var isSplashActive: Bool

    enum SplashPhase {
        case logoAppear
        case textAppear
        case particleStorm
        case done
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.07, blue: 0.09)
                .ignoresSafeArea()

            // Radial glow behind logo
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0, green: 0.6, blue: 0.45).opacity(0.3),
                    Color(red: 0, green: 0.4, blue: 0.3).opacity(0.1),
                    .clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: glowRadius
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .shadow(color: Color(red: 0.2, green: 0.88, blue: 0.69).opacity(0.3), radius: 24)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // App name
                Text("FitFlow")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
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
                    .opacity(textOpacity)

                // Tagline
                Text("Entrena, fluye, crece")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .opacity(textOpacity)

                Spacer()
                    .frame(height: 80)
            }

            // Floating particles
            ForEach(0..<20, id: \.self) { i in
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
                    .blur(radius: particleSize[i] > 4 ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Phase 1: Logo bounces in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Glow pulses in
        withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
            glowRadius = 300
        }

        // Phase 2: Text fades in
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            textOpacity = 1.0
        }

        // Phase 3: Particles appear
        for i in 0..<20 {
            let delay = Double.random(in: 1.0...2.0)
            let duration = Double.random(in: 1.5...3.0)
            withAnimation(
                .easeInOut(duration: duration)
                .delay(delay)
                .repeatForever(autoreverses: true)
            ) {
                particleOffset[i] = CGFloat.random(in: -80...(-40))
                particleOpacity[i] = Double.random(in: 0.2...0.7)
            }
        }

        // Finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeIn(duration: 0.5)) {
                logoOpacity = 0
                textOpacity = 0
                for i in 0..<20 {
                    particleOpacity[i] = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.4)) {
                    isSplashActive = false
                }
            }
        }
    }
}

#Preview {
    SplashView(isSplashActive: .constant(true))
}
