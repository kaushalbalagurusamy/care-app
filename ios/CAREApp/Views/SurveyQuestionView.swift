import SwiftUI

// MARK: - Screen 7: Dynamic Survey Questionnaire (Figma Frame 25:4)
public struct SurveyQuestionView: View {
    public let router: AppRouter
    @State public var session: AssessmentSessionState
    public let onComplete: (AssessmentResult) -> Void
    
    @State private var selectedOption: SurveyOption? = nil
    
    private let questions: [SurveyQuestion] = SurveyQuestion.mockQuestionBank
    
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
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar with Progress Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: false,
                showProfileButton: false,
                onBack: { router.pop() },
                onHome: { router.popToRoot() }
            )
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.Colors.dividerSubtle)
                        .frame(height: 3)
                    
                    Rectangle()
                        .fill(Theme.Colors.primary)
                        .frame(width: max(geo.size.width * CGFloat(session.progressRatio), 0), height: 3)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: session.progressRatio)
                }
            }
            .frame(height: 3)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Participant Context Badge
                    if let participant = currentParticipant {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Theme.Colors.primary.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(participant.person.initials)
                                        .font(Theme.Typography.subheadline)
                                        .foregroundColor(Theme.Colors.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Assessing: \(participant.person.name)")
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("Person \(session.currentParticipantIndex + 1) of \(session.participants.count)")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    
                    // Question Bubble Envelope
                    if let question = currentQuestion {
                        let primaryDomain = question.targetDomains.first?.domain ?? .calm
                        
                        BubbleCardContainer(title: nil) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Question \(session.currentQuestionIndex + 1) of \(questions.count)")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(primaryDomain.title)
                                        .font(Theme.Typography.miniBadge)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(primaryDomain.themeColor.opacity(0.2))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .clipShape(Capsule())
                                }
                                
                                Text(question.prompt)
                                    .font(Theme.Typography.questionText)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    // Likert Scale Options Stack
                    VStack(spacing: 10) {
                        ForEach(SurveyQuestion.standard5PointLikertOptions) { option in
                            let isSelected = (selectedOption?.id == option.id)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedOption = option
                                }
                            }) {
                                HStack {
                                    Text(option.text)
                                        .font(Theme.Typography.cardTitle)
                                        .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.dividerMedium, lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        
                                        if isSelected {
                                            Circle()
                                                .fill(Theme.Colors.primary)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(isSelected ? Theme.Colors.cardSurfaceSelected : Theme.Colors.background)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.dividerSubtle, lineWidth: isSelected ? 1.5 : 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Action Button (Dynamic "Next: {Name}" or "Complete Assessment")
                    PrimaryButton(
                        title: session.currentButtonTitle,
                        isEnabled: selectedOption != nil
                    ) {
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
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Previews
#Preview("Survey Question View") {
    let contacts = Person.mockFigmaContacts
    let participants = [
        AssessmentParticipant(person: contacts[0], percentTimeSpent: 0.30),
        AssessmentParticipant(person: contacts[1], percentTimeSpent: 0.25)
    ]
    let session = AssessmentSessionState(
        participants: participants,
        totalQuestionsPerPerson: 4
    )
    
    SurveyQuestionView(
        router: AppRouter(),
        session: session,
        onComplete: { _ in }
    )
}
