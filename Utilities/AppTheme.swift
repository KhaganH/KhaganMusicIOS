import SwiftUI

struct AppTheme {
    static let bgTop = Color(red: 0.12, green: 0.05, blue: 0.18)
    static let bgBottom = Color(red: 0.02, green: 0.01, blue: 0.05)
    static let primaryBackground = bgBottom
    static let secondaryBackground = Color(white: 0.15, opacity: 0.3)
    static let accentColor = Color(red: 0.95, green: 0.15, blue: 0.45) // Modern Pink/Magenta
    static let textColor = Color.white
    static let secondaryTextColor = Color.white.opacity(0.6)
    
    static let backgroundGradient = LinearGradient(
        colors: [bgTop, bgBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct GlassmorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func glassmorphic() -> some View {
        self.modifier(GlassmorphicBackground())
    }
}
