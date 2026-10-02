import SwiftUI

// MARK: - Screen 7: Dynamic Survey Questionnaire (Figma Frame 25:4)
public struct SurveyQuestionView: View {
    public let router: AppRouter
    @State public var session: AssessmentSessionState
    public let sourceSession: AssessmentSessionState
    public let onSessionUpdate: ((AssessmentSessionState) throws -> Void)?
    public let onComplete: (AssessmentResult) async throws -> Void
    public let onDiscardAssessment: (() throws -> Void)?
    
    @State private var selectedOption: SurveyOption? = nil
    @State private var showSaveConfirmation = false
    @State private var pendingDestination: AppRoute?
    @State private var isSubmitting = false
    @State private var submissionError: String?
    
    private let questions: [SurveyQuestion] = SurveyQuestion.full20QuestionBank
    
    public init(
        router: AppRouter,
        session: AssessmentSessionState,
        onSessionUpdate: ((AssessmentSessionState) throws -> Void)? = nil,
        onComplete: @escaping (AssessmentResult) async throws -> Void,
        onDiscardAssessment: (() throws -> Void)? = nil
    ) {
        self.router = router
        self._session = State(initialValue: session)
        self.sourceSession = session
        self.onSessionUpdate = onSessionUpdate
        self.onComplete = onComplete
        self.onDiscardAssessment = onDiscardAssessment
    }
    
    private var currentParticipant: AssessmentParticipant? {
        session.currentParticipant
    }
    
    private var currentQuestion: SurveyQuestion? {
        guard session.currentQuestionIndex < questions.count else { return nil }
        return questions[session.currentQuestionIndex]
    }

    private func formattedQuestionPrompt(question: SurveyQuestion, participant: AssessmentParticipant?) -> String {
        guard let name = participant?.person.name else {
            return "\(session.currentQuestionIndex + 1). \(question.prompt)"
        }
        
        var promptText = question.prompt
        promptText = promptText.replacingOccurrences(of: "How well do they sense", with: "How well does \(name) sense")
        promptText = promptText.replacingOccurrences(of: "sense what they are feeling", with: "sense what \(name) is feeling")
        promptText = promptText.replacingOccurrences(of: "how would they respond", with: "how would \(name) respond")
        promptText = promptText.replacingOccurrences(of: "a part of their life", with: "a part of \(name)'s life")
        promptText = promptText.replacingOccurrences(of: "around them", with: "around \(name)")
        promptText = promptText.replacingOccurrences(of: "with them", with: "with \(name)")
        promptText = promptText.replacingOccurrences(of: "to them", with: "to \(name)")
        promptText = promptText.replacingOccurrences(of: "this person", with: name)
        
        return "\(session.currentQuestionIndex + 1). \(promptText)"
    }
    
    private func advanceSession(with option: SurveyOption) {
        guard let q = currentQuestion else { return }
        let previous = session
        session.recordAnswer(for: q.id, option: option)
        
        if session.isComplete {
            guard session.isFullyAnswered else {
                submissionError = "The assessment needs five people and all 20 answers for each person before it can be submitted."
                return
            }
            do { try onSessionUpdate?(session) }
            catch { session = previous; submissionError = "Your answer could not be saved. Please try again."; return }
            guard !isSubmitting else { return }
            isSubmitting = true
            let engine = FlexibleScoringEngine()
            let result = engine.calculateResult(for: session)
            Task {
                do {
                    try await onComplete(result)
                    router.finishFlow(at: .surveyResults)
                } catch {
                    if error is AssessmentDailyLimitError {
                        submissionError = "You have already completed an assessment today. Your answers are saved; you can submit another assessment tomorrow."
                    } else {
                        submissionError = "Your assessment could not be saved. Your answers are still here; please retry."
                    }
                }
                isSubmitting = false
            }
        } else {
            let prevParticipantIndex = session.currentParticipantIndex
            _ = session.advance()
            do { try onSessionUpdate?(session) }
            catch { session = previous; submissionError = "Your answer could not be saved. Please try again."; return }
            selectedOption = session.currentAnswer
            if session.currentParticipantIndex != prevParticipantIndex {
                router.navigate(to: .personTransition)
            }
        }
    }

    private func requestLeave(to destination: AppRoute?) {
        guard !isSubmitting else { return }
        pendingDestination = destination
        showSaveConfirmation = true
    }

    private func goBackWithinAssessment() {
        guard !isSubmitting else { return }
        var previous = session
        guard previous.moveToPreviousQuestion() else { requestLeave(to: nil); return }
        do {
            try onSessionUpdate?(previous)
            session = previous
            selectedOption = previous.currentAnswer
        } catch {
            submissionError = "Your position could not be saved. Please try again."
        }
    }

    private func finishLeaving(save: Bool) {
        if save {
            if let selectedOption, let question = currentQuestion {
                session.recordAnswer(for: question.id, option: selectedOption)
                do { try onSessionUpdate?(session) }
                catch { submissionError = "Your answer could not be saved. Please try again."; return }
            }
        } else {
            do { try onDiscardAssessment?() }
            catch { submissionError = "Your saved assessment could not be discarded. Please try again."; return }
        }
        showSaveConfirmation = false
        if let pendingDestination {
            router.popToRoot()
            if pendingDestination != .home { router.navigate(to: pendingDestination) }
        } else {
            router.pop()
        }
    }
    
    public var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // Header Bar (Matching Figma Frame 7 with all top controls)
            HeaderNavBar(
                onBack: { goBackWithinAssessment() },
                onHome: { requestLeave(to: .home) },
                onSparkle: { requestLeave(to: .personalizedActionPlan) },
                onChart: { requestLeave(to: .pastResults) },
                onProfile: { requestLeave(to: .profile) }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Title Section (Figma Frame 25:4 & Node 239:8 - Participant name subtitle removed)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("C.A.R.E. Assessment")
                            .font(Theme.Typography.poppins(.bold, size: 24))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Reflect on how you’ve felt in this relationship over the last 2 weeks.")
                            .font(Theme.Typography.poppins(.regular, size: 12.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.top, 1)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Retained Feature: Progress Bar & Dual Counter
                    VStack(spacing: 4) {
                        HStack {
                            Text("Person \(session.currentParticipantIndex + 1) of \(max(session.participants.count, 1))")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                            
                            Text("Question \(session.currentQuestionIndex + 1) of \(questions.count)")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(hex: "#E2E8F0"))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Theme.Colors.primary)
                                    .frame(width: max(geo.size.width * CGFloat(session.progressRatio), 0), height: 4)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: session.progressRatio)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.vertical, 2)
                    
                    // Question Prompt (Figma Frame 7)
                    if let question = currentQuestion {
                        Text(formattedQuestionPrompt(question: question, participant: currentParticipant))
                            .font(Theme.Typography.poppins(.semiBold, size: session.isFinalQuestion ? 15.5 : 17))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 1)
                    }
                    
                    // 5-Point Likert Option Cards (Figma Frame 7 Left-Aligned Radio Style)
                    if let question = currentQuestion {
                        VStack(spacing: session.isFinalQuestion ? 8 : 9) {
                            ForEach(question.options) { option in
                                let isSelected = (selectedOption?.id == option.id)
                                
                                AssessmentAnswerOptionCard(text: option.text, state: isSelected ? .selected : .unselected, fontSize: session.isFinalQuestion ? 13 : 14) {
                                    withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                        selectedOption = option
                                    }
                                    guard !session.isFinalQuestion else { return }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        if router.currentRoute == .surveyQuestion && selectedOption?.id == option.id {
                                            advanceSession(with: option)
                                        }
                                    }
                                }
                                .accessibilityIdentifier("AssessmentOption_\(option.id)")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if session.isFinalQuestion {
                VStack(spacing: 0) {
                    Divider()
                        .background(Theme.Colors.dividerSubtle)

                    PrimaryButton(
                        title: "Submit",
                        trailingIcon: nil,
                        isEnabled: selectedOption != nil && !isSubmitting,
                        action: {
                            guard let chosen = selectedOption else { return }
                            advanceSession(with: chosen)
                        }
                    )
                    .accessibilityIdentifier("SurveyQuestionSubmitButton")
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                }
                .background(Theme.Colors.background)
            }
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { selectedOption = session.currentAnswer }
        .onChange(of: sourceSession) { _, updated in
            session = updated
            selectedOption = updated.currentAnswer
        }
        .alert("Assessment not saved", isPresented: Binding(get: { submissionError != nil }, set: { if !$0 { submissionError = nil } })) {
            Button("OK", role: .cancel) { submissionError = nil }
        } message: { Text(submissionError ?? "") }
        if showSaveConfirmation {
            SaveAssessmentConfirmationView(
                onSaveAssessment: { finishLeaving(save: true) },
                onDiscardAssessment: { finishLeaving(save: false) }
            )
        }
        }
    }
}

// MARK: - Previews
#Preview("Survey Question View (Figma Frame 7)") {
    let contacts = Person.mockFigmaContacts
    let participants = [
        AssessmentParticipant(person: contacts[0], percentTimeSpent: 0.30),
        AssessmentParticipant(person: contacts[1], percentTimeSpent: 0.25)
    ]
    let session = AssessmentSessionState(
        participants: participants,
        totalQuestionsPerPerson: 20
    )
    
    SurveyQuestionView(
        router: AppRouter(),
        session: session,
        onComplete: { _ in }
    )
}
