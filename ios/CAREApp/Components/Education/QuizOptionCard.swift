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

/// Common answer geometry for assessments and education quizzes.
public struct AssessmentAnswerOptionCard: View {
    public let text: String
    public let state: QuizOptionState
    public let isEnabled: Bool
    public let fontSize: CGFloat
    public let action: () -> Void

    public init(text: String, state: QuizOptionState, isEnabled: Bool = true, fontSize: CGFloat = 14, action: @escaping () -> Void) {
        self.text = text
        self.state = state
        self.isEnabled = isEnabled
        self.fontSize = fontSize
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(state == .unselected ? Theme.Colors.primary : state.borderColor, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if state != .unselected {
                        Circle()
                            .fill(state == .selected ? Theme.Colors.primary : state.borderColor)
                            .frame(width: 20, height: 20)
                        if state == .selected {
                            Circle().fill(Color.white).frame(width: 7, height: 7)
                        } else {
                            Image(systemName: state == .incorrect ? "xmark" : "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                Text(text)
                    .font(Theme.Typography.poppins(state == .unselected ? .regular : .semiBold, size: fontSize))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(state.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(state == .unselected ? Color.clear : state.borderColor, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }
}

// MARK: - Quiz Option Card (Figma Frame 18: 201:4 / Node 201:36)
public struct QuizOptionCard: View {
    public let option: QuizOption
    public let state: QuizOptionState
    public let isEnabled: Bool
    public let action: () -> Void
    
    public var minTouchTargetHeight: CGFloat { 48.0 }
    
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
        AssessmentAnswerOptionCard(text: option.text, state: state, isEnabled: isEnabled) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }
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
