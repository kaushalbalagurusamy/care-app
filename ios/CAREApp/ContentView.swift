import SwiftUI

// MARK: - Main Application Navigation Container
struct ContentView: View {
    @State private var router = AppRouter()
    @State private var appEnvironment: AppEnvironment
    @State private var profileSettings: ProfileSettingsStore
    @State private var contactsRevision = 0
    @State private var exerciseProgress: ExerciseProgressStore
    @State private var isShowingSplash: Bool = false
    
    // Shared State Across Assessment Funnel
    @State private var selectedPeople: [Person]
    @State private var allocations: [ParticipantAllocation]
    @State private var activeSession: AssessmentSessionState?
    @State private var storageError: String?
    @State private var latestResult: AssessmentResult?
    @State private var completedResult: AssessmentResult?
    
    @Environment(\.scenePhase) private var scenePhase

    private var hasCompletedAssessmentToday: Bool {
        (try? appEnvironment.draftStore.hasCompletedAssessment()) ?? true
    }

    private func discardAssessment() throws {
        try appEnvironment.draftStore.discardAssessmentDraft()
        activeSession = nil
        selectedPeople = []
        allocations = []
        AssessmentSessionState.clearDraft()
    }

    private var durableSelectedPeople: Binding<[Person]> {
        Binding(get: { selectedPeople }, set: { people in
            do {
                if people.isEmpty { try appEnvironment.draftStore.removeValue(key: "assessment-selection") }
                else { try appEnvironment.draftStore.saveValue(people, key: "assessment-selection") }
                selectedPeople = people
            } catch { storageError = "Your selected relationships could not be saved. Please try again." }
        })
    }

    private var durableAllocations: Binding<[ParticipantAllocation]> {
        Binding(get: { allocations }, set: { values in
            do {
                if values.isEmpty { try appEnvironment.draftStore.removeValue(key: "assessment-allocations") }
                else { try appEnvironment.draftStore.saveValue(values, key: "assessment-allocations") }
                allocations = values
            } catch { storageError = "Your relationship allocation could not be saved. Please try again." }
        })
    }

    private func reconcileContactReferences() async {
        guard let contacts = try? await appEnvironment.contactsRepo.fetchContacts() else { return }
        let byID = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
        selectedPeople = selectedPeople.compactMap { byID[$0.id] }
        if var session = activeSession {
            let participants = session.participants.compactMap { participant -> AssessmentParticipant? in
                guard let person = byID[participant.id] else { return nil }
                return AssessmentParticipant(person: person, percentTimeSpent: participant.percentTimeSpent)
            }
            if AssessmentSessionState.canStart(with: participants) {
                session.participants = participants
                activeSession = session
            } else { activeSession = nil }
        }
    }

    init(environment: AppEnvironment) {
        _appEnvironment = State(initialValue: environment)
        if !environment.draftStore.unreadableDraftKeys.isEmpty {
            _storageError = State(initialValue: "Some unfinished work could not be opened. Its data remains on this device. Please contact support before clearing app data.")
        }
        _exerciseProgress = State(initialValue: ExerciseProgressStore(sharedStore: environment.draftStore))
        _profileSettings = State(initialValue: ProfileSettingsStore(sharedStore: environment.draftStore))
        _selectedPeople = State(initialValue: (try? environment.draftStore.loadValue([Person].self, key: "assessment-selection")) ?? [])
        _allocations = State(initialValue: (try? environment.draftStore.loadValue([ParticipantAllocation].self, key: "assessment-allocations")) ?? [])
        let restored: AssessmentSessionState?
        var assessmentDraftUnreadable = false
        do { restored = try environment.draftStore.loadValue(AssessmentSessionState.self, key: "assessment-draft") }
        catch {
            restored = nil
            assessmentDraftUnreadable = true
            _storageError = State(initialValue: "Your saved assessment could not be opened. Its data remains on this device. Please contact support before clearing app data.")
        }
        let legacy = assessmentDraftUnreadable || ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--uitesting-") })
            ? nil : AssessmentSessionState.loadDraft()
        if restored == nil, let legacy {
            if (try? environment.draftStore.saveValue(legacy, key: "assessment-draft")) != nil {
                AssessmentSessionState.clearDraft()
            }
        }
        var recovered = restored ?? legacy
        if recovered?.id == nil, recovered != nil {
            recovered?.id = UUID()
            if let recovered { try? environment.draftStore.saveValue(recovered, key: "assessment-draft") }
        }
        _activeSession = State(initialValue: recovered)
    }
    
    var body: some View {
        @Bindable var r = router
        
        ZStack {
            NavigationStack(path: $r.path) {
                Group {
                if profileSettings.completedSetup {
                HomeView(
                    router: router,
                    activeSession: $activeSession,
                    onDiscardAssessment: {
                        do { try discardAssessment() }
                        catch { storageError = "Your assessment could not be discarded. Please try again." }
                    },
                    latestAssessmentDate: latestResult?.timestamp,
                    selectionInProgress: !selectedPeople.isEmpty
                )
                } else {
                    WelcomeAccountSetupView(router: router)
                }
                }
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
            .environment(exerciseProgress)
            .environment(profileSettings)
            
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
        .onChange(of: activeSession) { _, newSession in
            do {
                if let session = newSession, AssessmentSessionState.canStart(with: session.participants) { try appEnvironment.draftStore.saveValue(session, key: "assessment-draft") }
                else { try appEnvironment.draftStore.removeValue(key: "assessment-draft") }
            } catch { storageError = "Your assessment progress could not be saved. Please try again before leaving." }
        }
        .onChange(of: selectedPeople) { _, people in
            do { if people.isEmpty { try appEnvironment.draftStore.removeValue(key: "assessment-selection") }
                 else { try appEnvironment.draftStore.saveValue(people, key: "assessment-selection") } }
            catch { storageError = "Your selected relationships could not be saved." }
        }
        .onChange(of: allocations) { _, values in
            do { if values.isEmpty { try appEnvironment.draftStore.removeValue(key: "assessment-allocations") }
                 else { try appEnvironment.draftStore.saveValue(values, key: "assessment-allocations") } }
            catch { storageError = "Your relationship allocation could not be saved." }
        }
        .onChange(of: exerciseProgress.storageError) { _, message in
            if let message { storageError = message }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                if let activeSession, AssessmentSessionState.canStart(with: activeSession.participants) {
                    do { try appEnvironment.draftStore.saveValue(activeSession, key: "assessment-draft") }
                    catch { storageError = "Your assessment progress could not be saved." }
                }
            }
            appEnvironment.appLockManager.handleScenePhaseChange(newPhase)
        }
        .task {
            if let history = try? await appEnvironment.assessmentRepo.fetchAssessmentHistory() {
                latestResult = history.first
                if let activeSession, history.contains(where: { $0.id == activeSession.id }) {
                    self.activeSession = nil
                }
            }
            await reconcileContactReferences()
            contactsRevision += 1
        }
        .alert("Storage needs attention", isPresented: Binding(get: { storageError != nil }, set: { if !$0 { storageError = nil } })) {
            Button("OK", role: .cancel) { storageError = nil }
        } message: { Text(storageError ?? "") }
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
                    do { try discardAssessment() }
                    catch { storageError = "Your assessment could not be discarded. Please try again." }
                },
                latestAssessmentDate: latestResult?.timestamp,
                selectionInProgress: !selectedPeople.isEmpty
            )
            
        case .assessmentOverview:
            AssessmentOverviewView(router: router, latestAssessmentDate: latestResult?.timestamp, hasCompletedToday: hasCompletedAssessmentToday)
            
        case .surveyOverview:
            SurveyOverviewView(router: router)
            
        case .chooseRelationships:
            ChooseRelationshipsView(
                router: router,
                selectedPeople: durableSelectedPeople,
                refreshToken: contactsRevision
            )
            
        case .relationshipFrequency:
            RelationshipFrequencyView(
                router: router,
                selectedPeople: selectedPeople,
                allocations: durableAllocations,
                onProceed: { participants in
                    guard AssessmentSessionState.canStart(with: participants) else { return false }
                    guard AssessmentDailyPolicy.canStart(after: latestResult?.timestamp), !hasCompletedAssessmentToday else {
                        storageError = "You’ve already completed an assessment today. You can begin another tomorrow."
                        return false
                    }
                    let session = AssessmentSessionState(
                        participants: participants,
                        totalQuestionsPerPerson: 20
                    )
                    do {
                        try appEnvironment.draftStore.saveValue(session, key: "assessment-draft")
                        activeSession = session
                        return true
                    } catch {
                        storageError = "Your assessment could not be started because its progress was not saved. Please try again."
                        return false
                    }
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
                    },
                    onPreviousQuestion: {
                        var previous = session
                        guard previous.moveToPreviousQuestion() else { return }
                        do {
                            try appEnvironment.draftStore.saveValue(previous, key: "assessment-draft")
                            activeSession = previous
                            router.pop()
                        } catch { storageError = "Your assessment position could not be saved. Please try again." }
                    },
                    onDiscardAssessment: { try discardAssessment() }
                )
            } else {
                ChooseRelationshipsView(
                    router: router,
                    selectedPeople: durableSelectedPeople,
                    refreshToken: contactsRevision
                )
            }
            
        case .surveyQuestion:
            if let session = activeSession {
                SurveyQuestionView(
                    router: router,
                    session: session,
                    onSessionUpdate: { updated in
                        try appEnvironment.draftStore.saveValue(updated, key: "assessment-draft")
                        activeSession = updated
                    },
                    onComplete: { result in
                        try appEnvironment.draftStore.commitAssessmentResult(result)
                        latestResult = result
                        completedResult = result
                        activeSession = nil
                        selectedPeople = []
                        allocations = []
                    },
                    onDiscardAssessment: { try discardAssessment() }
                )
            } else {
                ChooseRelationshipsView(
                    router: router,
                    selectedPeople: durableSelectedPeople,
                    refreshToken: contactsRevision
                )
            }
            
        case .surveyResults:
            if let latestResult { SurveyResultsV2View(result: latestResult) }
            else { NoAssessmentResultsView(router: router) }
            
        case .surveyResultsExpanded:
            SurveyResultsExpandedView(router: router)
            
        case .pastResults:
            PastResultsV2View(recentResult: completedResult)
            
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
            if let latestResult { PersonalizedActionPlanView(router: router, result: latestResult) }
            else { NoAssessmentResultsView(router: router) }

        case .prmLibrary:
            PRMLibraryView()
            
        case .profile:
            ProfileView(router: router, onDataCleared: { scope in
                if scope == "relationships" || scope == "all" {
                    selectedPeople = []
                    allocations = []
                    activeSession = nil
                    contactsRevision += 1
                }
                if scope == "assessments" || scope == "all" {
                    completedResult = nil
                    activeSession = nil
                    latestResult = nil
                    selectedPeople = []
                    allocations = []
                }
            })
            
        case .careInfo:
            CAREInformationView()
            
        case .addRelationship:
            AddRelationshipView(onChanged: { contactsRevision += 1; Task { await reconcileContactReferences() } })

        case .editContact(let id):
            AddRelationshipView(editingContactID: id, onChanged: { contactsRevision += 1; Task { await reconcileContactReferences() } }, onDeleted: { deletedID in
                selectedPeople.removeAll { $0.id == deletedID }
                allocations.removeAll { $0.id == deletedID }
                if activeSession?.participants.contains(where: { $0.id == deletedID }) == true { activeSession = nil }
            })
            
        case .calmExercises:
            CalmExercisesView()

        case .acceptedExercises:
            ExerciseCategoryHomeView(category: .accepted)

        case .resonantExercises:
            ExerciseCategoryHomeView(category: .resonant)

        case .energeticExercises:
            ExerciseCategoryHomeView(category: .energetic)
            
        case .watchFunny:
            WatchFunnyExerciseView()
            
        case .keepPhoto:
            KeepPhotoExerciseView()
            
        case .belongingList:
            BelongingListExerciseView()

        case .shareSomethingSmall:
            ShareExerciseView(kind: .small)

        case .mirrorEmotion:
            MirrorExerciseView(kind: .emotion)

        case .mirrorLovedOne:
            MirrorExerciseView(kind: .lovedOne)

        case .shareSomethingNew:
            ShareExerciseView(kind: .new)

        case .connectionCountdown:
            ConnectionCountdownExerciseView()

        case .guidedExercise(let exerciseID):
            GuidedExerciseView(exerciseID: exerciseID)
            
        case .careResultsExercises:
            if let latestResult { CAREResultsExercisesView(result: latestResult) }
            else { NoAssessmentResultsView(router: router) }
            
        case .exerciseComplete:
            ExerciseCompleteView()

        case .exerciseCompleteFor(let exerciseID):
            ExerciseCompleteView(exerciseID: exerciseID)
            
        case .surveyResultsV2:
            if let latestResult { SurveyResultsV2View(result: latestResult) }
            else { NoAssessmentResultsView(router: router) }
            
        case .pastResultsV2:
            PastResultsV2View(recentResult: completedResult)

        case .historicalSurveyResults(let resultID):
            HistoricalSurveyResultsDestination(resultID: resultID)
        }
    }
}

private struct HistoricalSurveyResultsDestination: View {
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment
    @Environment(AppRouter.self) private var router: AppRouter
    let resultID: UUID
    @State private var result: AssessmentResult?
    @State private var didLoad = false

    var body: some View {
        Group {
            if let result {
                SurveyResultsV2View(result: result)
            } else if didLoad {
                VStack(spacing: 20) {
                    HeaderNavBar(showBackButton: true, onBack: { router.pop() })
                    Spacer()
                    Text("This assessment is unavailable")
                        .font(Theme.Typography.screenTitle)
                    Text("The saved results could not be found on this device.")
                        .font(Theme.Typography.poppins(.regular, size: 14))
                    Spacer()
                }
                .foregroundColor(Theme.Colors.textPrimary)
            } else {
                ProgressView("Loading saved results")
            }
        }
        .task(id: resultID) {
            result = (try? await appEnvironment.assessmentRepo.fetchAssessmentHistory())?.first { $0.id == resultID }
            didLoad = true
        }
    }
}

private struct NoAssessmentResultsView: View {
    let router: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            HeaderNavBar(showBackButton: true, onBack: { router.pop() })
            Spacer()
            Image(systemName: "chart.pie")
                .font(.system(size: 44))
                .foregroundStyle(Theme.Colors.primary)
            Text("No assessment results yet")
                .font(Theme.Typography.poppins(.bold, size: 22))
            Text("Complete an assessment with five relationships to see your C.A.R.E. scores and recommendations.")
                .font(Theme.Typography.poppins(.regular, size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.horizontal, 30)
            PrimaryButton(title: "Start Assessment") { router.navigate(to: .assessmentOverview) }
                .padding(.horizontal, 20)
            Spacer()
        }
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - Previews
#Preview {
    ContentView(environment: .preview)
}

// SwiftUI has no "never" horizontal bounce mode. Place this probe inside only
// horizontal scroll views so vertical pages keep their normal elastic scrolling.
struct NoHorizontalBounceScrollView<Content: View>: View {
    let showsIndicators: Bool
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            content.background(HorizontalBounceDisabler())
        }
    }
}

private struct HorizontalBounceDisabler: UIViewRepresentable {
    func makeUIView(context: Context) -> Probe { Probe(frame: .zero) }
    func updateUIView(_ uiView: Probe, context: Context) { uiView.disableBounce() }

    final class Probe: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            DispatchQueue.main.async { [weak self] in self?.disableBounce() }
        }

        func disableBounce() {
            var ancestor = superview
            while let view = ancestor {
                if let scrollView = view as? UIScrollView {
                    scrollView.bounces = false
                    return
                }
                ancestor = view.superview
            }
        }
    }
}
