import SwiftUI

// MARK: - Education Quiz View (Figma Frame 18: 201:4 with 3-Question Stepper)
public struct EducationQuizView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    
    public let topic: EducationTopic
    public let onReturn: (() -> Void)?
    public let onHome: (() -> Void)?
    public let onCompleteQuiz: ((Bool) -> Void)?
    
    @State public var questions: [QuizQuestion]
    @State public var currentQuestionIndex: Int = 0
    @State public var selectedOptionLetter: String? = nil
    @State public var hasSubmittedCurrent: Bool = false
    @State public var sessionScore: Int = 0
    @State public var isSessionFinished: Bool = false
    @State public var wasPoolReset: Bool = false
    @State public var remainingInPool: Int = 0
    
    public init(
        topic: EducationTopic,
        questions: [QuizQuestion]? = nil,
        selectedOptionLetter: String? = nil,
        hasSubmitted: Bool = false,
        onReturn: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil,
        onCompleteQuiz: ((Bool) -> Void)? = nil
    ) {
        self.topic = topic
        let pool = questions ?? (topic.quizBank.isEmpty ? [topic.quiz] : Array(topic.quizBank.prefix(3)))
        self._questions = State(initialValue: pool)
        self._selectedOptionLetter = State(initialValue: selectedOptionLetter)
        self._hasSubmittedCurrent = State(initialValue: hasSubmitted)
        
        var initialScore = 0
        if hasSubmitted, let letter = selectedOptionLetter, let first = pool.first, letter == first.correctOptionLetter {
            initialScore = 1
        }
        self._sessionScore = State(initialValue: initialScore)
        
        self.onReturn = onReturn
        self.onHome = onHome
        self.onCompleteQuiz = onCompleteQuiz
    }
    
    public var hasSubmitted: Bool {
        hasSubmittedCurrent
    }
    
    public var activeQuestion: QuizQuestion {
        if currentQuestionIndex < questions.count {
            return questions[currentQuestionIndex]
        }
        return topic.quiz
    }
    
    public var isCorrect: Bool {
        guard let selected = selectedOptionLetter else { return false }
        return selected == activeQuestion.correctOptionLetter
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
                    if !isSessionFinished {
                        quizStepperContent
                    } else {
                        quizResultsContent
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .careAppBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // If running with real AppEnvironment and default questions weren't manually overridden, fetch a fresh randomized session
            if let appEnvironment = appEnvironment, questions.count <= 1 || questions == Array(topic.quizBank.prefix(3)) {
                if let session = try? await appEnvironment.educationRepo.fetchNextQuizSession(for: topic, count: 3) {
                    self.questions = session.questions
                    self.wasPoolReset = session.wasPoolReset
                    self.remainingInPool = session.remainingInPoolAfterSession
                }
            }
        }
    }
    
    // MARK: - Active Stepper Content
    @ViewBuilder
    private var quizStepperContent: some View {
        // Quiz Header Title
        Text("\(topic.title) Quiz")
            .font(Theme.Typography.poppins(.bold, size: 26))
            .foregroundColor(Theme.Colors.textPrimary)
            .lineSpacing(2)
            .padding(.top, 4)
            .accessibilityAddTraits(.isHeader)
        
        // Progress Segment Bar
        if questions.count > 1 {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0..<questions.count, id: \.self) { idx in
                        Capsule()
                            .fill(idx <= currentQuestionIndex ? Theme.Colors.primary : Theme.Colors.dividerSubtle)
                            .frame(height: 5)
                    }
                }
                
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(Theme.Typography.poppins(.medium, size: 12.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    Spacer()
                    
                    if wasPoolReset {
                        Text("✨ Pool Refreshed")
                            .font(Theme.Typography.poppins(.medium, size: 11))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.Colors.primary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.bottom, 4)
        }
        
        // Question Prompt Box
        Text("\(currentQuestionIndex + 1). \(activeQuestion.prompt)")
            .font(Theme.Typography.poppins(.bold, size: 17))
            .foregroundColor(Theme.Colors.textPrimary)
            .lineSpacing(3.5)
            .fixedSize(horizontal: false, vertical: true)
        
        // Answer Option Cards
        VStack(spacing: 12) {
            ForEach(activeQuestion.options) { option in
                let optionState = presentationState(for: option)
                QuizOptionCard(
                    option: option,
                    state: optionState,
                    isEnabled: !hasSubmittedCurrent,
                    action: {
                        handleOptionSelection(option.letter)
                    }
                )
            }
        }
        
        // Rationale Box (Revealed upon answering)
        if hasSubmittedCurrent {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                    
                    Text("CORRECT ANSWER: \(activeQuestion.correctOptionLetter)")
                        .font(Theme.Typography.poppins(.bold, size: 13))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                Text(activeQuestion.rationale)
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
        
        // Stepper Navigation CTA Button
        if hasSubmittedCurrent {
            if currentQuestionIndex < questions.count - 1 {
                PrimaryButton(
                    title: "Next Question",
                    icon: "arrow.right",
                    action: {
                        advanceToNextQuestion()
                    }
                )
                .padding(.top, 8)
                .padding(.bottom, 28)
            } else {
                PrimaryButton(
                    title: "View Results",
                    icon: "sparkles",
                    action: {
                        finishSession()
                    }
                )
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        } else {
            // Cancel / Return CTA during quiz
            SecondaryButton(
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
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }
    
    // MARK: - Session Results Screen
    @ViewBuilder
    private var quizResultsContent: some View {
        let isMastered = (sessionScore == questions.count && questions.count > 0)
        let percent = Int((Double(sessionScore) / Double(max(1, questions.count))) * 100)
        
        VStack(spacing: 20) {
            // Mastery Icon Badge
            ZStack {
                Circle()
                    .fill(isMastered ? Theme.Colors.primary.opacity(0.12) : Color.orange.opacity(0.12))
                    .frame(width: 80, height: 80)
                
                Image(systemName: isMastered ? "checkmark.seal.fill" : "book.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(isMastered ? Theme.Colors.primary : Color.orange)
            }
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text(isMastered ? "Mastery Achieved!" : (sessionScore == 2 ? "Almost There!" : "Keep Going!"))
                    .font(Theme.Typography.poppins(.bold, size: 24))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if isMastered {
                    Text("Perfect score! You answered 3 of 3 correctly (100%). Category completed.")
                        .font(Theme.Typography.poppins(.medium, size: 14.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("You answered \(sessionScore) of \(questions.count) correctly (\(percent)%). Score 3 of 3 to achieve category mastery and earn your checkmark.")
                        .font(Theme.Typography.poppins(.medium, size: 14.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Actions
            VStack(spacing: 12) {
                PrimaryButton(
                    title: isMastered ? "Practice Again" : "Try Again",
                    action: {
                        startAnotherSet()
                    }
                )
                
                SecondaryButton(
                    title: "Return to \(topic.title)",
                    action: {
                        if let onReturn = onReturn {
                            onReturn()
                        } else {
                            router?.pop()
                        }
                    }
                )
            }
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
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
            correctLetter: activeQuestion.correctOptionLetter,
            hasSubmitted: hasSubmittedCurrent
        )
    }
    
    private func handleOptionSelection(_ letter: String) {
        selectedOptionLetter = letter
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            hasSubmittedCurrent = true
        }
        if letter == activeQuestion.correctOptionLetter {
            sessionScore += 1
        }
        
        // If single-question session, record outcome directly
        if questions.count == 1 {
            let passed = (letter == activeQuestion.correctOptionLetter)
            if let appEnvironment = appEnvironment {
                Task {
                    try? await appEnvironment.educationRepo.recordQuizSessionResult(
                        slug: topic.slug,
                        questionIds: [activeQuestion.id],
                        score: passed ? 1 : 0,
                        totalQuestions: 1
                    )
                }
            }
            onCompleteQuiz?(passed)
        }
    }
    
    private func advanceToNextQuestion() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentQuestionIndex += 1
            selectedOptionLetter = nil
            hasSubmittedCurrent = false
        }
    }
    
    private func finishSession() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isSessionFinished = true
        }
        let passed = (sessionScore == questions.count && questions.count > 0)
        if let appEnvironment = appEnvironment {
            Task {
                try? await appEnvironment.educationRepo.recordQuizSessionResult(
                    slug: topic.slug,
                    questionIds: questions.map(\.id),
                    score: sessionScore,
                    totalQuestions: questions.count
                )
            }
        }
        onCompleteQuiz?(passed)
    }
    
    private func startAnotherSet() {
        Task {
            if let appEnvironment = appEnvironment,
               let session = try? await appEnvironment.educationRepo.fetchNextQuizSession(for: topic, count: 3) {
                await MainActor.run {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        self.questions = session.questions
                        self.wasPoolReset = session.wasPoolReset
                        self.remainingInPool = session.remainingInPoolAfterSession
                        self.currentQuestionIndex = 0
                        self.selectedOptionLetter = nil
                        self.hasSubmittedCurrent = false
                        self.sessionScore = 0
                        self.isSessionFinished = false
                    }
                }
            } else {
                await MainActor.run {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        self.currentQuestionIndex = 0
                        self.selectedOptionLetter = nil
                        self.hasSubmittedCurrent = false
                        self.sessionScore = 0
                        self.isSessionFinished = false
                    }
                }
            }
        }
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
