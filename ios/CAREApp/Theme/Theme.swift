import SwiftUI

// MARK: - Theme Hub & Global View Modifiers
// Note: Theme.Colors, Theme.Typography, Theme.Spacing, Theme.Radius are defined in their respective token files.

public extension View {
    /// Applies standard CARE App background styling to a view
    func careAppBackground() -> some View {
        self.background(Theme.Colors.surfaceSecondary.ignoresSafeArea())
    }
    
    /// Applies standardized card container styling with subtle border
    func careCardStyle(
        backgroundColor: Color = Theme.Colors.background,
        cornerRadius: CGFloat = Theme.Radius.card,
        borderColor: Color = Theme.Colors.dividerSubtle
    ) -> some View {
        self
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}
