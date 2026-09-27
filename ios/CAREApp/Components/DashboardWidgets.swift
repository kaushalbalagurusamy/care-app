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
    
    public init(
        title: String,
        subtitle: String,
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
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            if hasResumeControls {
                onResume?()
            } else {
                action()
            }
        }) {
            ZStack {
                // Background 3D Render Art (Exact 149pt height matching Jayme's Frame 5:4)
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(350.0 / 149.0, contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 149)
                    .clipped()
                    .grayscale(hasResumeControls ? 0.92 : 0.0)
                    .saturation(hasResumeControls ? 0.15 : 1.0)
                    .brightness(hasResumeControls ? -0.06 : 0.0)
                
                // Grayed-out In-Progress Dark Tint & Frost Overlay
                if hasResumeControls {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#0F172A").opacity(0.42),
                                    Color(hex: "#1E293B").opacity(0.52)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Content Layer - Vertically Centered along button midpoint
                HStack(alignment: .center, spacing: 14) {
                    // Left: Frosted Glass Circular Icon Badge (Preserved from our version)
                    Circle()
                        .fill(hasResumeControls ? Color.white.opacity(0.16) : Color.white.opacity(0.24))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(hasResumeControls ? Color.white.opacity(0.28) : Color.white.opacity(0.40), lineWidth: 1.5)
                        )
                        .overlay(
                            Image(iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .opacity(hasResumeControls ? 0.85 : 1.0)
                        )
                    
                    Spacer()
                    
                    // Right: Title and Subtitle / Resume Controls (Aligned to Vertical Midpoint)
                    VStack(alignment: .trailing, spacing: hasResumeControls ? 6 : 2) {
                        if hasResumeControls {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(Color(hex: "#F59E0B"))
                                    .frame(width: 6, height: 6)
                                Text("In Progress")
                                    .font(Theme.Typography.poppins(.medium, size: 10))
                                    .foregroundColor(Color.white.opacity(0.92))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.28))
                            .clipShape(Capsule())
                        }
                        
                        Text(title)
                            .font(Theme.Typography.poppins(.semiBold, size: hasResumeControls ? 22 : 26))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.28), radius: 3, x: 0, y: 1)
                        
                        if hasResumeControls {
                            // Figma Node 244:560: buttons-row with Resume and Discard
                            HStack(spacing: 8) {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    onResume?()
                                }) {
                                    Text("Resume")
                                        .font(Theme.Typography.poppins(.semiBold, size: 12))
                                        .foregroundColor(Color(hex: "#0F1D40"))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("ResumeAssessmentButton")
                                
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    onDiscard?()
                                }) {
                                    Text("Discard")
                                        .font(Theme.Typography.poppins(.medium, size: 12))
                                        .foregroundColor(Color.white.opacity(0.90))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("DiscardAssessmentButton")
                            }
                        } else {
                            Text(subtitle)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .foregroundColor(.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.20), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 22)
            }
            .frame(height: 149)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(ActionCardButtonStyle(hasResumeControls: hasResumeControls))
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityLabel(hasResumeControls ? "\(title), In Progress. Resume or Discard." : "\(title), \(subtitle)")
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
