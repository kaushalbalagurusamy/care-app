import SwiftUI

// MARK: - Screen 7: Dynamic Survey Questionnaire (Figma Frame 25:4)
public struct SurveyQuestionView: View {
    public let router: AppRouter
    @State public var session: AssessmentSessionState
    public let onSessionUpdate: ((AssessmentSessionState) -> Void)?
    public let onComplete: (AssessmentResult) -> Void
    
    @State private var selectedOption: SurveyOption? = nil
    
    private let questions: [SurveyQuestion] = SurveyQuestion.full20QuestionBank
    
    public init(
        router: AppRouter,
        session: AssessmentSessionState,
        onSessionUpdate: ((AssessmentSessionState) -> Void)? = nil,
        onComplete: @escaping (AssessmentResult) -> Void
    ) {
        self.router = router
        self._session = State(initialValue: session)
        self.onSessionUpdate = onSessionUpdate
        self.onComplete = onComplete
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
        session.recordAnswer(for: q.id, option: option)
        onSessionUpdate?(session)
        
        if session.isComplete {
            let engine = FlexibleScoringEngine()
            let result = engine.calculateResult(for: session)
            onComplete(result)
            router.navigate(to: .surveyResults)
        } else {
            let prevParticipantIndex = session.currentParticipantIndex
            _ = session.advance()
            onSessionUpdate?(session)
            selectedOption = nil
            if session.currentParticipantIndex != prevParticipantIndex {
                router.navigate(to: .personTransition)
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar (Matching Figma Frame 7 with all top controls)
            HeaderNavBar()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Title Section (Figma Frame 25:4 & Node 25:20 - Directives #12 & #13)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("C.A.R.E. Assessment:")
                            .font(Theme.Typography.poppins(.bold, size: 24))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(currentParticipant?.person.name ?? "Assessment")
                            .font(Theme.Typography.poppins(.semiBold, size: 18))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text("Reflect on how you’ve felt in this relationship over the last 2 weeks.")
                            .font(Theme.Typography.poppins(.regular, size: 12.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.top, 1)
                    }
                    .padding(.top, 2)
                    
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
                            .font(Theme.Typography.poppins(.semiBold, size: 15.5))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 1)
                    }
                    
                    // 5-Point Likert Option Cards (Figma Frame 7 Left-Aligned Radio Style)
                    if let question = currentQuestion {
                        VStack(spacing: 8) {
                            ForEach(question.options) { option in
                                let isSelected = (selectedOption?.id == option.id)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                        selectedOption = option
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        if selectedOption?.id == option.id {
                                            advanceSession(with: option)
                                        }
                                    }
                                }) {
                                    HStack(alignment: .center, spacing: 12) {
                                        // Left-Side Circular Radio Indicator
                                        ZStack {
                                            if isSelected {
                                                Circle()
                                                    .fill(Theme.Colors.primary)
                                                    .frame(width: 20, height: 20)
                                                
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 7, height: 7)
                                            } else {
                                                Circle()
                                                    .stroke(Theme.Colors.primary, lineWidth: 1.5)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        
                                        // Option Description Text
                                        Text(option.text)
                                            .font(Theme.Typography.poppins(isSelected ? .semiBold : .regular, size: 13))
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Theme.Colors.cardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Pinned Bottom Action Bar (Directive #15: Submit button, remove arrow)
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                PrimaryButton(
                    title: (session.isLastQuestionForCurrentPerson && session.isLastParticipant) ? "Complete Assessment" : "Submit",
                    trailingIcon: nil,
                    isEnabled: selectedOption != nil,
                    action: {
                        guard let chosen = selectedOption else { return }
                        advanceSession(with: chosen)
                    }
                )
                .accessibilityIdentifier("SurveyQuestionNextButton")
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Theme.Colors.background)
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
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
