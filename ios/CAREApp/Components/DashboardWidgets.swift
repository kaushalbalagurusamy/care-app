import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4 — 100% Direct Vector/Raster Export)
public struct ActionCardView: View {
    public let imageName: String
    public let action: () -> Void
    
    public init(
        imageName: String,
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(imageName)
                .resizable()
                .aspectRatio(350.0 / 170.0, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleCardButtonStyle())
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

// MARK: - Interactive Scale Button Style
struct ScaleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Daily Streak Pill Widget (Figma Frame 5:47 — Direct Figma Sparkles & Poppins)
public struct StreakBadgeView: View {
    public let daysCount: Int
    
    public init(daysCount: Int = 5) {
        self.daysCount = daysCount
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // Direct Figma Sparkles Icon
            Image("icon_sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            
            // Streak Text (Poppins SemiBold 13pt)
            HStack(spacing: 4) {
                Text("Daily Streak:")
                    .font(Theme.Typography.menuLabel)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(daysCount) Days Active")
                    .font(Theme.Typography.menuLabel)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(Theme.Colors.cardSurface)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Dashboard Widgets") {
    VStack(spacing: 14) {
        ActionCardView(imageName: "card_education_full", action: {})
        ActionCardView(imageName: "card_assessment_full", action: {})
        ActionCardView(imageName: "card_exercises_full", action: {})
        StreakBadgeView(daysCount: 5)
    }
    .padding(20)
    .background(Color.white)
}
