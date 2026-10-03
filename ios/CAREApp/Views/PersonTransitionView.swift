import SwiftUI

// MARK: - Screen: Participant Interstitial Transition Screen (Figma Frames 241:467 & 241:492)
public struct PersonTransitionView: View {
    public let router: AppRouter
    public let session: AssessmentSessionState
    public var onStart: (() -> Void)? = nil
    public var onPreviousQuestion: (() -> Void)? = nil
    public var onDiscardAssessment: (() throws -> Void)? = nil
    @State private var showSaveConfirmation = false
    @State private var pendingDestination: AppRoute?
    @State private var discardError: String?
    
    public init(
        router: AppRouter,
        session: AssessmentSessionState,
        onStart: (() -> Void)? = nil,
        onPreviousQuestion: (() -> Void)? = nil,
        onDiscardAssessment: (() throws -> Void)? = nil
    ) {
        self.router = router
        self.session = session
        self.onStart = onStart
        self.onPreviousQuestion = onPreviousQuestion
        self.onDiscardAssessment = onDiscardAssessment
    }
    
    private var currentParticipant: AssessmentParticipant? {
        session.currentParticipant
    }

    private func requestLeave(to destination: AppRoute?) {
        pendingDestination = destination
        if session.hasStarted {
            showSaveConfirmation = true
        } else {
            navigateAway()
        }
    }

    private func navigateAway() {
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
            // Header Bar
            HeaderNavBar(
                showBackButton: true,
                onBack: {
                    if session.currentParticipantIndex > 0, let onPreviousQuestion { onPreviousQuestion() }
                    else { requestLeave(to: nil) }
                },
                onHome: { requestLeave(to: .home) },
                onSparkle: { requestLeave(to: .personalizedActionPlan) },
                onChart: { requestLeave(to: .pastResults) },
                onProfile: { requestLeave(to: .profile) }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Avatar Outer
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.primary.opacity(0.12))
                            .frame(width: 88, height: 88)
                        
                        if let initials = currentParticipant?.person.initials, !initials.isEmpty {
                            Text(initials)
                                .font(Theme.Typography.poppins(.bold, size: 30))
                                .foregroundColor(Theme.Colors.primary)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Identity Group
                    VStack(spacing: 8) {
                        Text("Person \(session.currentParticipantIndex + 1) of \(max(session.participants.count, 1))")
                            .font(Theme.Typography.poppins(.medium, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text(currentParticipant?.person.name ?? "Participant")
                            .font(Theme.Typography.poppins(.bold, size: 26))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        // Metadata Pills
                        HStack(spacing: 8) {
                            if let category = currentParticipant?.person.displayCategory, !category.isEmpty {
                                Text(category)
                                    .font(Theme.Typography.poppins(.medium, size: 12))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Theme.Colors.surfaceSecondary)
                                    .clipShape(Capsule())
                            }
                            
                        }
                        .padding(.top, 2)
                    }
                    
                    // Assessment Card Container
                    VStack(alignment: .leading, spacing: 12) {
                        Text("C.A.R.E. Assessment")
                            .font(Theme.Typography.poppins(.bold, size: 18))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        let name = currentParticipant?.person.name ?? "this individual"
                        Text("You are about to complete the C.A.R.E. assessment for \(name), which consists of \(session.totalQuestionsPerPerson) questions describing your relationship over the last 2 weeks.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.cardSurface)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Pinned Bottom Action Bar
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                PrimaryButton(
                    title: "Start Assessment",
                    trailingIcon: "arrow.right",
                    action: {
                        if let onStart = onStart {
                            onStart()
                        } else {
                            if router.currentRoute != .surveyQuestion {
                                router.navigate(to: .surveyQuestion)
                            }
                        }
                    }
                )
                .accessibilityIdentifier("StartPersonAssessmentButton")
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Theme.Colors.background)
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Assessment not discarded", isPresented: Binding(get: { discardError != nil }, set: { if !$0 { discardError = nil } })) {
            Button("OK", role: .cancel) { discardError = nil }
        } message: { Text(discardError ?? "") }
        if showSaveConfirmation {
            SaveAssessmentConfirmationView(
                onSaveAssessment: {
                    showSaveConfirmation = false
                    navigateAway()
                },
                onDiscardAssessment: {
                    do {
                        try onDiscardAssessment?()
                        showSaveConfirmation = false
                        navigateAway()
                    } catch {
                        discardError = "Your saved assessment could not be discarded. Please try again."
                    }
                }
            )
        }
        }
    }
}

// MARK: - Previews
#Preview("Person Transition View") {
    let contacts = Person.mockFigmaContacts
    let participants = [
        AssessmentParticipant(person: contacts[0], percentTimeSpent: 0.30),
        AssessmentParticipant(person: contacts[1], percentTimeSpent: 0.25)
    ]
    let session = AssessmentSessionState(
        participants: participants,
        totalQuestionsPerPerson: 20
    )
    return PersonTransitionView(router: AppRouter(), session: session)
}
