import SwiftUI

// MARK: - Design Tokens

/// Centralized design tokens for the FitFlow app.
/// All colors, spacing, typography, and shape constants live here.
/// Change once, update everywhere.
enum DS {

    // MARK: - Colors

    enum Colors {
        /// Brand green gradient (top-leading → bottom-trailing).
        static let brandStart = Color(red: 0, green: 0.85, blue: 0.65)
        static let brandEnd   = Color(red: 0, green: 0.6, blue: 0.4)
        static let brandMid   = Color(red: 0, green: 0.8, blue: 0.6)

        /// Dark background used on Auth + Splash screens.
        static let darkBG = Color(red: 0.07, green: 0.07, blue: 0.09)
        static let canvas = Color(red: 0.035, green: 0.04, blue: 0.045)
        static let surface = Color(red: 0.075, green: 0.085, blue: 0.09)
        static let hairline = Color.white.opacity(0.11)

        /// Semantic phase colors (shared by abs + running timers).
        static let work  = Color.red
        static let rest  = Color.green
        static let walk  = Color.teal
        static let info  = Color.blue

        /// Running-specific phase colors.
        static let ritmoAlto   = Color.red
        static let ritmoMedio  = Color.orange
        static let ritmoSuave  = Color.green
        static let caminar     = Color.teal
        static let distancia   = Color.purple
        static let nota        = Color.blue
        static let cronometro  = Color.indigo
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 36
    }

    // MARK: - Typography

    enum FontSize {
        static let hero: CGFloat = 56
        static let largeTitle: CGFloat = 42
        static let title: CGFloat = 28
        static let headline: CGFloat = 17
        static let subheadline: CGFloat = 15
        static let body: CGFloat = 17
        static let caption: CGFloat = 13
        static let caption2: CGFloat = 11
        static let icon: CGFloat = 13
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let avatar: CGFloat = 100
        static let avatarPicker: CGFloat = 32
        static let exerciseThumb: CGFloat = 44
        static let playerIcon: CGFloat = 90
        static let statIcon: CGFloat = 24
        static let formIcon: CGFloat = 18
    }
}

// MARK: - Reusable Gradient

extension LinearGradient {
    /// The brand green gradient used across the app (avatar borders, buttons, accents).
    static let brandGradient = LinearGradient(
        colors: [DS.Colors.brandStart, DS.Colors.brandEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark-to-light gradient for background overlays.
    static let subtleGradient = LinearGradient(
        colors: [.blue.opacity(0.15), .purple.opacity(0.1), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Reusable View Modifiers

struct BrandCircleBorder: ViewModifier {
    var lineWidth: CGFloat = 2.5
    func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .overlay(
                Circle().stroke(LinearGradient.brandGradient, lineWidth: lineWidth)
            )
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DS.Spacing.lg)
            .background(DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(LinearGradient.brandGradient)
                    .frame(width: 3)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.sm).stroke(DS.Colors.hairline))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = .accentColor
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.md)
            .background(isEnabled ? tint : DS.Colors.surface, in: RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(isEnabled ? .clear : DS.Colors.hairline)
            )
            .opacity(isEnabled ? 1 : 0.48)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.md)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FormFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: DS.Radius.sm))
    }
}

struct PlayerControlButton: View {
    let systemName: String
    let size: CGFloat
    let font: Font
    let action: () -> Void

    init(systemName: String, size: CGFloat = 64, font: Font = .title, action: @escaping () -> Void) {
        self.systemName = systemName
        self.size = size
        self.font = font
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(font)
                .foregroundStyle(.primary)
                .frame(width: size, height: size)
                .background(.thinMaterial, in: Circle())
        }
    }
}

struct FadeInModifier: ViewModifier {
    @Binding var isVisible: Bool
    var delay: Double = 0
    var yOffset: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : yOffset)
            .animation(.easeOut(duration: 0.5).delay(delay), value: isVisible)
    }
}

extension View {
    func brandCircleBorder(lineWidth: CGFloat = 2.5) -> some View {
        modifier(BrandCircleBorder(lineWidth: lineWidth))
    }

    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func formFieldStyle() -> some View {
        modifier(FormFieldStyle())
    }

    func fadeIn(_ isVisible: Binding<Bool>, delay: Double = 0, yOffset: CGFloat = 20) -> some View {
        modifier(FadeInModifier(isVisible: isVisible, delay: delay, yOffset: yOffset))
    }
}
