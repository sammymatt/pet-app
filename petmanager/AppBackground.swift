import SwiftUI

struct AppBackground: View {
    let style: Style
    @Environment(\.colorScheme) var colorScheme

    enum Style {
        case health
        case profile
        case home
        case settings
        case login
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        switch style {
        case .health:
            return colorScheme == .dark
                ? [Color(red: 0.1, green: 0.25, blue: 0.18), Color(red: 0.08, green: 0.18, blue: 0.25)]
                : [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.3, green: 0.6, blue: 0.8)]
        case .profile:
            return colorScheme == .dark
                ? [Color(red: 0.3, green: 0.2, blue: 0.1), Color(red: 0.25, green: 0.15, blue: 0.18)]
                : [Color(red: 0.95, green: 0.7, blue: 0.4), Color(red: 0.9, green: 0.5, blue: 0.6)]
        case .home:
            return colorScheme == .dark
                ? [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.18, green: 0.1, blue: 0.25)]
                : [Color(red: 0.4, green: 0.6, blue: 0.95), Color(red: 0.6, green: 0.4, blue: 0.9)]
        case .settings:
            return colorScheme == .dark
                ? [Color(red: 0.15, green: 0.1, blue: 0.28), Color(red: 0.2, green: 0.15, blue: 0.25)]
                : [Color(red: 0.5, green: 0.4, blue: 0.9), Color(red: 0.7, green: 0.5, blue: 0.8)]
        case .login:
            return colorScheme == .dark
                ? [Color(red: 0.18, green: 0.1, blue: 0.22), Color(red: 0.1, green: 0.18, blue: 0.25)]
                : [Color(red: 0.6, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.6, blue: 0.9)]
        }
    }
}
