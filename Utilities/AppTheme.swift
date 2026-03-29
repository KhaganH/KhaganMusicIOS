import SwiftUI

struct AppTheme {
    static let primaryBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let secondaryBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let accentColor = Color(red: 0.85, green: 0.1, blue: 0.45) // Modern Pink/Purple
    static let textColor = Color.white
    static let secondaryTextColor = Color.gray
}

struct GlassmorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassmorphic() -> some View {
        self.modifier(GlassmorphicBackground())
    }
}
