import SwiftUI

// MARK: - Quiz Option Presentation State
public enum QuizOptionState: Hashable, Sendable {
    case unselected
    case selected
    case correct
    case incorrect
    
    public var backgroundColor: Color {
        switch self {
        case .unselected:
            return Theme.Colors.cardSurface
        case .selected:
            return Theme.Colors.cardSurfaceSelected
        case .correct:
            return Color(hex: "#EAF7EE")
        case .incorrect:
            return Color(hex: "#FDEEF1")
        }
    }
    
    public var borderColor: Color {
        switch self {
        case .unselected:
            return Theme.Colors.dividerSubtle
        case .selected:
            return Theme.Colors.primary
        case .correct:
            return Color(hex: "#5D9C59")
        case .incorrect:
            return Color(hex: "#E07A5F")
        }
    }
    
    public var letterBadgeBackground: Color {
        switch self {
        case .unselected:
            return Color.white
        case .selected:
            return Theme.Colors.primary
        case .correct:
            return Color(hex: "#5D9C59")
        case .incorrect:
            return Color(hex: "#E07A5F")
        }
    }
    
    public var letterBadgeForeground: Color {
        switch self {
        case .unselected:
            return Theme.Colors.primary
        case .selected, .correct, .incorrect:
            return Color.white
        }
    }
}

// MARK: - Quiz Option Card (Figma Frame 18: 201:4 / Node 201:36)
public struct QuizOptionCard: View {
    public let option: QuizOption
    public let state: QuizOptionState
    public let isEnabled: Bool
    public let action: () -> Void
    
    public var minTouchTargetHeight: CGFloat { 56.0 }
    
    public init(
        option: QuizOption,
        state: QuizOptionState = .unselected,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.option = option
        self.state = state
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard isEnabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                // Circular Letter Badge (A / B / C / D)
                ZStack {
                    Circle()
                        .fill(state.letterBadgeBackground)
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    
                    Text(option.letter)
                        .font(Theme.Typography.poppins(.bold, size: 14))
                        .foregroundColor(state.letterBadgeForeground)
                }
                .frame(width: 32, height: 32)
                
                // Option Text
                Text(option.text)
                    .font(Theme.Typography.poppins(.medium, size: 14))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineSpacing(2)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Trailing Feedback Icon (Checkmark or Cross)
                Group {
                    switch state {
                    case .correct:
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#5D9C59"))
                    case .incorrect:
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#E07A5F"))
                    case .unselected, .selected:
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: minTouchTargetHeight)
            .background(state.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(state.borderColor, lineWidth: state == .unselected ? 1 : 1.8)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Option \(option.letter): \(option.text). State: \(stateDescription)")
        .accessibilityHint(isEnabled ? "Double tap to select this answer" : "")
        .accessibilityAddTraits(state == .selected ? [.isButton, .isSelected] : .isButton)
    }
    
    private var stateDescription: String {
        switch state {
        case .unselected: return "Unselected"
        case .selected: return "Selected"
        case .correct: return "Correct answer"
        case .incorrect: return "Incorrect answer"
        }
    }
}

// MARK: - Previews
#Preview("Quiz Option Card Matrix") {
    VStack(spacing: 12) {
        QuizOptionCard(
            option: QuizOption(letter: "A", text: "It amplifies sympathetic arousal to prepare the body for defensive action."),
            state: .incorrect,
            action: {}
        )
        
        QuizOptionCard(
            option: QuizOption(letter: "B", text: "It dampens the acute stress response and signals safety down through the body."),
            state: .correct,
            action: {}
        )
        
        QuizOptionCard(
            option: QuizOption(letter: "C", text: "It triggers the release of cortisol to heighten cognitive awareness during conflict."),
            state: .unselected,
            action: {}
        )
        
        QuizOptionCard(
            option: QuizOption(letter: "D", text: "It directly activates the social pain center in the brain when isolation occurs."),
            state: .selected,
            action: {}
        )
    }
    .padding(20)
    .background(Theme.Colors.background)
}
