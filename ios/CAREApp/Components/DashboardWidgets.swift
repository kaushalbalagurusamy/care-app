import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4 — 350x196pt)
public struct ActionCardView: View {
    public let number: String
    public let title: String
    public let subtitle: String
    public let iconSystemName: String
    public let backgroundImageName: String
    public let action: () -> Void
    
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
                // Background 3D Render Art
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 196)
                    .clipped()
                
                // Content Overlay Layout Matching Figma Frame 5:21
                HStack(spacing: 0) {
                    // Left Column: Index & Icon
                    VStack(alignment: .leading, spacing: 16) {
                        Text(number)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.leading, 8)
                        
                        // Translucent Glass Icon Circle
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: iconSystemName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    // Right Column: Title & Subtitle
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 196)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleCardButtonStyle())
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

// MARK: - Daily Streak Pill Widget (Figma Frame 5:47 — 350x44pt Capsule)
public struct StreakBadgeView: View {
    public let daysCount: Int
    
    public init(daysCount: Int = 5) {
        self.daysCount = daysCount
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // Blue Sparkles Icon
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.primary)
            
            // Streak Text
            HStack(spacing: 4) {
                Text("Daily Streak:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(daysCount) Days Active")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Theme.Colors.cardSurface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Dashboard Widgets") {
    VStack(spacing: 16) {
        ActionCardView(number: "01", title: "Education", subtitle: "Learn Wellness", iconSystemName: "book.fill", backgroundImageName: "card_education_bg", action: {})
        ActionCardView(number: "02", title: "Assessment", subtitle: "Track Mind", iconSystemName: "heart.fill", backgroundImageName: "card_assessment_bg", action: {})
        ActionCardView(number: "03", title: "Exercises", subtitle: "Active Care", iconSystemName: "bolt.fill", backgroundImageName: "card_exercises_bg", action: {})
        StreakBadgeView(daysCount: 5)
    }
    .padding(20)
    .background(Color.white)
}
