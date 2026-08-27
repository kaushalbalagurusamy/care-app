import SwiftUI

// MARK: - Screen 7: Dynamic Survey Questionnaire (Figma Frame 25:4)
public struct SurveyQuestionView: View {
    public let router: AppRouter
    @State public var session: AssessmentSessionState
    public let onComplete: (AssessmentResult) -> Void
    
    @State private var selectedOption: SurveyOption? = nil
    
    private let questions: [SurveyQuestion] = SurveyQuestion.full20QuestionBank
    
    public init(
        router: AppRouter,
        session: AssessmentSessionState,
        onComplete: @escaping (AssessmentResult) -> Void
    ) {
        self.router = router
        self._session = State(initialValue: session)
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
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar (Matching Figma Frame 7 with all top controls)
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section (Figma Frame 7: "C.A.R.E. Assessment:\n{Participant Name}")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("C.A.R.E. Assessment:")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(currentParticipant?.person.name ?? "Assessment")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.top, 4)
                    
                    // Retained Feature: Progress Bar & Dual Counter
                    VStack(spacing: 6) {
                        HStack {
                            Text("Person \(session.currentParticipantIndex + 1) of \(max(session.participants.count, 1))")
                                .font(Theme.Typography.poppins(.medium, size: 13))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                            
                            Text("Question \(session.currentQuestionIndex + 1) of \(questions.count)")
                                .font(Theme.Typography.poppins(.medium, size: 13))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(hex: "#E2E8F0"))
                                    .frame(height: 5)
                                
                                Capsule()
                                    .fill(Theme.Colors.primary)
                                    .frame(width: max(geo.size.width * CGFloat(session.progressRatio), 0), height: 5)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: session.progressRatio)
                            }
                        }
                        .frame(height: 5)
                    }
                    .padding(.vertical, 2)
                    
                    // Question Prompt (Figma Frame 7)
                    if let question = currentQuestion {
                        Text(formattedQuestionPrompt(question: question, participant: currentParticipant))
                            .font(Theme.Typography.poppins(.bold, size: 17))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                    
                    // 5-Point Likert Option Cards (Figma Frame 7 Left-Aligned Radio Style)
                    if let question = currentQuestion {
                        VStack(spacing: 12) {
                            ForEach(question.options) { option in
                                let isSelected = (selectedOption?.id == option.id)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                                        selectedOption = option
                                    }
                                }) {
                                    HStack(alignment: .center, spacing: 14) {
                                        // Left-Side Circular Radio Indicator
                                        ZStack {
                                            if isSelected {
                                                Circle()
                                                    .fill(Theme.Colors.primary)
                                                    .frame(width: 22, height: 22)
                                                
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 8, height: 8)
                                            } else {
                                                Circle()
                                                    .stroke(Theme.Colors.primary, lineWidth: 2)
                                                    .frame(width: 22, height: 22)
                                            }
                                        }
                                        
                                        // Option Description Text
                                        Text(option.text)
                                            .font(Theme.Typography.poppins(isSelected ? .semiBold : .regular, size: 14.5))
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                                    .background(Theme.Colors.cardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Action Button (Figma Frame 7 "Next")
                    Button(action: {
                        guard let chosen = selectedOption, let q = currentQuestion else { return }
                        session.recordAnswer(for: q.id, option: chosen)
                        
                        if session.isComplete {
                            let engine = FlexibleScoringEngine()
                            let result = engine.calculateResult(for: session)
                            onComplete(result)
                            router.navigate(to: .surveyResults)
                        } else {
                            _ = session.advance()
                            selectedOption = nil
                        }
                    }) {
                        Text(session.currentButtonTitle == "Complete Assessment" ? "Complete Assessment" : "Next")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(selectedOption != nil ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(selectedOption == nil)
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
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
