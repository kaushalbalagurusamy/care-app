import SwiftUI

// MARK: - Education Quiz View (Figma Frame 18: 201:4)
public struct EducationQuizView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    public let topic: EducationTopic
    public let onReturn: (() -> Void)?
    public let onHome: (() -> Void)?
    public let onCompleteQuiz: ((Bool) -> Void)?
    
    @State public var selectedOptionLetter: String? = nil
    @State public var hasSubmitted: Bool = false
    
    public init(
        topic: EducationTopic,
        selectedOptionLetter: String? = nil,
        hasSubmitted: Bool = false,
        onReturn: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil,
        onCompleteQuiz: ((Bool) -> Void)? = nil
    ) {
        self.topic = topic
        self._selectedOptionLetter = State(initialValue: selectedOptionLetter)
        self._hasSubmitted = State(initialValue: hasSubmitted)
        self.onReturn = onReturn
        self.onHome = onHome
        self.onCompleteQuiz = onCompleteQuiz
    }
    
    public var isCorrect: Bool {
        selectedOptionLetter == topic.quiz.correctOptionLetter
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Header Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: {
                    if let onReturn = onReturn {
                        onReturn()
                    } else {
                        router?.pop()
                    }
                },
                onHome: onHome
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Quiz Header Title
                    Text("\(topic.title) Quiz")
                        .font(Theme.Typography.poppins(.bold, size: 26))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(2)
                        .padding(.top, 4)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Question Prompt Box
                    Text("1. \(topic.quiz.prompt)")
                        .font(Theme.Typography.poppins(.bold, size: 17))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(3.5)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Answer Option Cards
                    VStack(spacing: 12) {
                        ForEach(topic.quiz.options) { option in
                            let optionState = presentationState(for: option)
                            QuizOptionCard(
                                option: option,
                                state: optionState,
                                isEnabled: !hasSubmitted,
                                action: {
                                    handleOptionSelection(option.letter)
                                }
                            )
                        }
                    }
                    
                    // Rationale Box (Revealed upon answering)
                    if hasSubmitted {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Theme.Colors.primary)
                                
                                Text("CORRECT ANSWER: \(topic.quiz.correctOptionLetter)")
                                    .font(Theme.Typography.poppins(.bold, size: 13))
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            
                            Text(topic.quiz.rationale)
                                .font(Theme.Typography.poppins(.regular, size: 13.5))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Return Action CTA Button
                    PrimaryButton(
                        title: "Return to \(topic.title)",
                        icon: "arrow.left",
                        action: {
                            if let onReturn = onReturn {
                                onReturn()
                            } else {
                                router?.pop()
                            }
                        }
                    )
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 20)
            }
        }
        .careAppBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - State Calculation Helper
    public static func evaluateOption(
        letter: String,
        selectedLetter: String?,
        correctLetter: String,
        hasSubmitted: Bool
    ) -> QuizOptionState {
        guard hasSubmitted else {
            return selectedLetter == letter ? .selected : .unselected
        }
        
        if letter == correctLetter {
            return .correct
        } else if letter == selectedLetter {
            return .incorrect
        } else {
            return .unselected
        }
    }
    
    public func presentationState(for option: QuizOption) -> QuizOptionState {
        Self.evaluateOption(
            letter: option.letter,
            selectedLetter: selectedOptionLetter,
            correctLetter: topic.quiz.correctOptionLetter,
            hasSubmitted: hasSubmitted
        )
    }
    
    private func handleOptionSelection(_ letter: String) {
        selectedOptionLetter = letter
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            hasSubmitted = true
        }
        let passed = (letter == topic.quiz.correctOptionLetter)
        onCompleteQuiz?(passed)
    }
}

// MARK: - Previews
#Preview("Education Quiz View") {
    if let manifest = try? EducationManifestLoader.loadBundledManifest(),
       let first = manifest.first {
        EducationQuizView(topic: first)
            .environment(AppRouter())
    } else {
        Text("Manifest not loaded")
    }
}
