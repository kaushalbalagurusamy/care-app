import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4 — Full Width 3D Art & Centered Content)
public struct ActionCardView: View {
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let backgroundImageName: String
    public let action: () -> Void
    
    private let cardHeight: CGFloat = 176.0
    
    public init(
        title: String,
        subtitle: String,
        iconName: String,
        backgroundImageName: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.backgroundImageName = backgroundImageName
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                // Background 3D Render Art (Exact Figma Image Fill Filling Card)
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: cardHeight)
                    .clipped()
                
                // Vertically Centered Content Layout
                HStack(alignment: .center, spacing: 16) {
                    // Left Column: Frosted Glass Icon Badge (Vertically Centered)
                    Circle()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    // Right Column: Title & Subtitle (Vertically Centered with Icon)
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(title)
                            .font(Theme.Typography.poppins(.bold, size: 21))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(Theme.Typography.poppins(.medium, size: 12))
                            .foregroundColor(.white.opacity(0.92))
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
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
        ActionCardView(title: "Education", subtitle: "Learn Wellness", iconName: "icon_book_open", backgroundImageName: "card_education_bg", action: {})
        ActionCardView(title: "Assessment", subtitle: "Track Mind", iconName: "icon_heart_pulse", backgroundImageName: "card_assessment_bg", action: {})
        ActionCardView(title: "Exercises", subtitle: "Active Care", iconName: "icon_activity", backgroundImageName: "card_exercises_bg", action: {})
        StreakBadgeView(daysCount: 5)
    }
    .padding(20)
    .background(Color.white)
}
