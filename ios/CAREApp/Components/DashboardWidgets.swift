import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4 — Scaled to 164pt for 1-screen fit)
public struct ActionCardView: View {
    public let number: String
    public let title: String
    public let subtitle: String
    public let iconSystemName: String
    public let backgroundImageName: String
    public let action: () -> Void
    
    private let cardHeight: CGFloat = 162.0
    
    public init(
        number: String,
        title: String,
        subtitle: String,
        iconSystemName: String = "heart.fill",
        backgroundImageName: String,
        action: @escaping () -> Void
    ) {
        self.number = number
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
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
                // Background 3D Render Art strictly bounded to frame
                Color.clear
                    .overlay(
                        Image(backgroundImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .clipped()
                
                // Content Overlay Layout Matching Figma Frame 5:21
                HStack(spacing: 0) {
                    // Left Column: Index & Icon
                    VStack(alignment: .leading, spacing: 12) {
                        Text(number)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.leading, 8)
                        
                        // Translucent Glass Icon Circle
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: iconSystemName)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    // Right Column: Title & Subtitle
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(title)
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
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

// MARK: - Daily Streak Pill Widget (Figma Frame 5:47 — 350x40pt Capsule)
public struct StreakBadgeView: View {
    public let daysCount: Int
    
    public init(daysCount: Int = 5) {
        self.daysCount = daysCount
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // Blue Sparkles Icon
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.Colors.primary)
            
            // Streak Text
            HStack(spacing: 4) {
                Text("Daily Streak:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(daysCount) Days Active")
                    .font(.system(size: 13, weight: .bold))
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
        ActionCardView(number: "01", title: "Education", subtitle: "Learn Wellness", iconSystemName: "book.fill", backgroundImageName: "card_education_bg", action: {})
        ActionCardView(number: "02", title: "Assessment", subtitle: "Track Mind", iconSystemName: "heart.fill", backgroundImageName: "card_assessment_bg", action: {})
        ActionCardView(number: "03", title: "Exercises", subtitle: "Active Care", iconSystemName: "bolt.fill", backgroundImageName: "card_exercises_bg", action: {})
        StreakBadgeView(daysCount: 5)
    }
    .padding(20)
    .background(Color.white)
}
