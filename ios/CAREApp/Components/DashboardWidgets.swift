import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4 — Direct Original Photos & Proportional Scaling)
public struct ActionCardView: View {
    public let imageName: String
    public let title: String
    public let subtitle: String
    public let maxHeight: CGFloat?
    public let action: () -> Void
    
    public init(
        imageName: String,
        title: String = "",
        subtitle: String = "",
        maxHeight: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.maxHeight = maxHeight
        self.action = action
    }
    
    // Backward-compatible initializer for legacy callers
    public init(
        title: String,
        subtitle: String,
        iconName: String = "",
        backgroundImageName: String = "",
        maxHeight: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        let resolved = backgroundImageName.replacingOccurrences(of: "_bg", with: "_full")
        self.imageName = resolved.isEmpty ? "card_assessment_full" : resolved
        self.maxHeight = maxHeight
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
                .aspectRatio(350.0 / 196.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .ifLet(maxHeight) { view, height in
                    view.frame(maxHeight: height)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(ScaleCardButtonStyle())
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityLabel(title.isEmpty ? imageName : "\(title), \(subtitle)")
    }
}

// MARK: - View Extension for Optional Modifiers
extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
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
