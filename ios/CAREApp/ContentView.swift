import SwiftUI

// MARK: - Main Application Navigation Container
struct ContentView: View {
    @State private var router = AppRouter()
    @State private var appEnvironment = AppEnvironment()
    @State private var isShowingSplash: Bool = false
    
    // Shared State Across Assessment Funnel
    @State private var selectedPeople: [Person] = Array(Person.mockFigmaContacts.prefix(5))
    @State private var allocations: [ParticipantAllocation] = []
    @State private var activeSession: AssessmentSessionState? = nil
    @State private var latestResult: AssessmentResult = AssessmentResult.figmaMockResult
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        @Bindable var r = router
        
        ZStack {
            NavigationStack(path: $r.path) {
                HomeView(
                    router: router,
                    activeSession: $activeSession,
                    onDiscardAssessment: {
                        activeSession = nil
                    }
                )
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(for: AppRoute.self) { route in
                        viewForRoute(route)
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                    }
            }
            .environment(router)
            .environment(appEnvironment)
            
            // Splash Screen Overlay
            if isShowingSplash {
                LoadingView(onFinished: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowingSplash = false
                    }
                })
                .transition(.opacity)
                .zIndex(100)
            }
            
            // App Lock & Multitasking Privacy Shield Overlay
            if appEnvironment.appLockManager.isLocked || appEnvironment.appLockManager.isShieldActive {
                AppLockView()
                    .environment(appEnvironment)
                    .transition(.opacity)
                    .zIndex(200)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            appEnvironment.appLockManager.handleScenePhaseChange(newPhase)
        }
    }
    
    // MARK: - Screen Route Dispatcher
    @ViewBuilder
    private func viewForRoute(_ route: AppRoute) -> some View {
        switch route {
        case .loading:
            LoadingView(onFinished: {
                router.popToRoot()
            })
            
        case .home:
            HomeView(
                router: router,
                activeSession: $activeSession,
                onDiscardAssessment: {
                    activeSession = nil
                }
            )
            
        case .assessmentOverview:
            AssessmentOverviewView(router: router)
            
        case .surveyOverview:
            SurveyOverviewView(router: router)
            
        case .chooseRelationships:
            ChooseRelationshipsView(
                router: router,
                selectedPeople: $selectedPeople
            )
            
        case .relationshipFrequency:
            RelationshipFrequencyView(
                router: router,
                selectedPeople: selectedPeople,
                allocations: $allocations,
                onProceed: { participants in
                    activeSession = AssessmentSessionState(
                        participants: participants,
                        totalQuestionsPerPerson: 20
                    )
                }
            )
            
        case .personTransition:
            if let session = activeSession {
                PersonTransitionView(
                    router: router,
                    session: session,
                    onStart: {
                        if router.path.contains(.surveyQuestion) {
                            router.pop()
                        } else {
                            router.navigate(to: .surveyQuestion)
                        }
                    }
                )
            } else {
                let defaultParticipants = selectedPeople.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
                let session = AssessmentSessionState(
                    participants: defaultParticipants.isEmpty ? [AssessmentParticipant(person: Person.mockFigmaContacts[0], percentTimeSpent: 1.0)] : defaultParticipants,
                    totalQuestionsPerPerson: 20
                )
                PersonTransitionView(
                    router: router,
                    session: session,
                    onStart: {
                        router.navigate(to: .surveyQuestion)
                    }
                )
            }
            
        case .surveyQuestion:
            if let session = activeSession {
                SurveyQuestionView(
                    router: router,
                    session: session,
                    onSessionUpdate: { updated in
                        activeSession = updated
                    },
                    onComplete: { result in
                        latestResult = result
                        activeSession = nil
                        Task {
                            try? await appEnvironment.assessmentRepo.saveAssessmentResult(result)
                        }
                    }
                )
            } else {
                // Fallback initialized session
                let defaultParticipants = selectedPeople.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
                let session = AssessmentSessionState(
                    participants: defaultParticipants,
                    totalQuestionsPerPerson: 20
                )
                SurveyQuestionView(
                    router: router,
                    session: session,
                    onSessionUpdate: { updated in
                        activeSession = updated
                    },
                    onComplete: { result in
                        latestResult = result
                        activeSession = nil
                        Task {
                            try? await appEnvironment.assessmentRepo.saveAssessmentResult(result)
                        }
                    }
                )
            }
            
        case .surveyResults:
            SurveyResultsView(
                router: router,
                result: latestResult
            )
            
        case .surveyResultsExpanded:
            SurveyResultsExpandedView(router: router)
            
        case .pastResults:
            PastResultsView(router: router)
            
        case .education:
            EducationTopicsView()
            
        case .educationDetail(let topic):
            TopicDetailView(topic: topic)
            
        case .educationQuiz(let topic):
            EducationQuizView(topic: topic)
            
        case .exercises:
            ExercisesView(router: router)
            
        case .welcomeAccountSetup:
            WelcomeAccountSetupView(router: router)
            
        case .personalizedActionPlan:
            PersonalizedActionPlanView(router: router, result: latestResult)
            
        case .profile:
            ProfileView(router: router)
        }
    }
}

// MARK: - Previews
#Preview {
    ContentView()
}
