import SwiftUI

enum Brand {
    static let red = Color(red: 0.76, green: 0.05, blue: 0.12)
    static let redDark = Color(red: 0.48, green: 0.02, blue: 0.07)
    static let cream = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.075, blue: 0.07, alpha: 1)
            : UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1)
    })
    static let peach = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.34, green: 0.20, blue: 0.16, alpha: 1)
            : UIColor(red: 0.98, green: 0.84, blue: 0.73, alpha: 1)
    })
    static let green = Color(red: 0.08, green: 0.48, blue: 0.31)
}

struct WarmBackground: View {
    var body: some View {
        LinearGradient(colors: [Brand.cream, Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Brand.red.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SoftCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 14, y: 7)
    }
}

extension View {
    func softCard() -> some View { modifier(SoftCardModifier()) }
}

struct AvatarView: View {
    let participant: Participant
    var size: CGFloat = 44

    var body: some View {
        Text(participant.initials)
            .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(participant.isHost ? Brand.red : .orange, in: Circle())
            .accessibilityLabel("\(participant.name), \(participant.city)")
    }
}

struct SectionHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Brand.red)
            Text(title)
                .font(.largeTitle.bold())
                .minimumScaleFactor(0.75)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Int {
    var rupees: String { "₹\(formatted(.number.grouping(.automatic)))" }
}
