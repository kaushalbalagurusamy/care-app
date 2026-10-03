import SwiftUI

// MARK: - Dashboard Module Action Card (No Numbers, Centered Midpoint Icon, 50% Larger Typography)
public struct ActionCardView: View {
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let backgroundImageName: String
    public let hasResumeControls: Bool
    public let onResume: (() -> Void)?
    public let onDiscard: (() -> Void)?
    public let action: () -> Void
    public var progressTitle: String { title == "Education" ? "Quiz in Progress" : "\(title) in progress" }
    
    public init(
        title: String,
        subtitle: String = "",
        iconName: String,
        backgroundImageName: String,
        hasResumeControls: Bool = false,
        onResume: (() -> Void)? = nil,
        onDiscard: (() -> Void)? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.backgroundImageName = backgroundImageName
        self.hasResumeControls = hasResumeControls
        self.onResume = onResume
        self.onDiscard = onDiscard
        self.action = action
    }
    
    // Backward-compatible initializer
    public init(
        imageName: String,
        title: String = "",
        subtitle: String = "",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        let bg = imageName.replacingOccurrences(of: "_full", with: "_bg")
        self.backgroundImageName = bg
        if imageName.contains("education") {
            self.iconName = "icon_book_open"
        } else if imageName.contains("assessment") {
            self.iconName = "icon_heart_pulse"
        } else {
            self.iconName = "icon_activity"
        }
        self.hasResumeControls = false
        self.onResume = nil
        self.onDiscard = nil
        self.action = action
    }
    
    public var body: some View {
        if hasResumeControls && title == "Assessment" {
            // In-progress assessment card directly from Figma Frame 491:203
            ZStack(alignment: .bottom) {
                Image("card_assessment_resume_bg")
                    .resizable()
                    .aspectRatio(350.0 / 149.0, contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 149)
                    .clipped()
                
                // Interactive buttons mapped to Figma Frame 496:99 (Resume & Discard touch targets)
                HStack(spacing: 8) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onResume?()
                    }) {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Resume")
                    .accessibilityIdentifier("ResumeAssessmentButton")
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onDiscard?()
                    }) {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Discard")
                    .accessibilityIdentifier("DiscardAssessmentButton")
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 31.5)
            }
            .frame(height: 149)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Assessment in progress")
        } else if hasResumeControls {
            ZStack {
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(350.0 / 149.0, contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 149)
                    .clipped()
                    .grayscale(1)
                Color.gray.opacity(0.82)
                VStack(spacing: 10) {
                    Text(progressTitle)
                        .font(Theme.Typography.poppins(.bold, size: 17))
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        resumeAction("Continue", action: onResume)
                        resumeAction("Discard", action: onDiscard)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: 149)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .accessibilityElement(children: .contain)
        } else {
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }) {
                ZStack(alignment: .bottomLeading) {
                    Image(backgroundImageName)
                        .resizable()
                        .aspectRatio(350.0 / 149.0, contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 149)
                        .clipped()

                    // Keep the three home-card artworks text-free so titles remain crisp at every scale.
                    if title == "Education" || title == "Assessment" || title == "Exercises" {
                        LinearGradient(
                            colors: [Color(red: 0.10, green: 0.28, blue: 0.45).opacity(0.55), .clear],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                        .allowsHitTesting(false)

                        Text(title)
                            .font(Theme.Typography.poppins(.bold, size: 17))
                            .foregroundStyle(.white)
                            .padding(.leading, 16)
                            .padding(.bottom, 24)
                    }
                }
                .frame(height: 149)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(ActionCardButtonStyle(hasResumeControls: false))
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityLabel(title)
        }
    }

    private func resumeAction(_ title: String, action: (() -> Void)?) -> some View {
        Button { action?() } label: {
            Text(title)
                .font(Theme.Typography.poppins(.semiBold, size: 13))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(.black.opacity(0.28))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(title)\(self.title)Button")
    }
}

/// Fits the card underneath while exposing explicit resume and discard actions.
public struct InProgressCardOverlay: View {
    public let title: String
    public let cornerRadius: CGFloat
    public let onContinue: () -> Void
    public let onDiscard: () -> Void

    public init(title: String, cornerRadius: CGFloat = 18, onContinue: @escaping () -> Void, onDiscard: @escaping () -> Void) {
        self.title = title
        self.cornerRadius = cornerRadius
        self.onContinue = onContinue
        self.onDiscard = onDiscard
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(Theme.Typography.poppins(.semiBold, size: 12))
                .foregroundStyle(.white)
                .lineLimit(1)
            HStack(spacing: 8) {
                action("Continue", systemName: "arrow.uturn.forward", action: onContinue)
                action("Discard", systemName: "trash", action: onDiscard)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }

    private func action(_ title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemName)
                .font(Theme.Typography.poppins(.semiBold, size: 11))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(Color.black.opacity(0.25))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(title)InProgressButton")
    }
}

// MARK: - Action Card Button Style
private struct ActionCardButtonStyle: ButtonStyle {
    let hasResumeControls: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(!hasResumeControls && configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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

// MARK: - Daily Streak / Assessment Interval Pill Widget (Figma Frame 5:47)
public struct StreakBadgeView: View {
    public let daysUntilNextAssessment: Int
    public let title: String
    
    public init(daysUntilNextAssessment: Int = 3, title: String = "Days until next assessment:") {
        self.daysUntilNextAssessment = daysUntilNextAssessment
        self.title = title
    }
    
    // Backward-compatible initializer for existing callers
    public init(daysCount: Int) {
        self.daysUntilNextAssessment = daysCount
        self.title = "Days until next assessment:"
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            CalendarIcon(size: 16, color: Theme.Colors.primary)
            
            HStack(spacing: 4) {
                Text(title)
                    .font(Theme.Typography.menuLabel)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(daysUntilNextAssessment) days")
                    .font(Theme.Typography.menuLabel)
                    .foregroundColor(Theme.Colors.primary)
            }
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
