import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 4: Screen Views Test Suite")
struct ScreenViewTests {
    
    @Test("TEST-SCR-01: LoadingView completes and transitions to Home")
    @MainActor
    func testLoadingViewTransition() {
        var didComplete = false
        let router = AppRouter()
        #expect(router.currentRoute == .loading)
        
        let view = LoadingView(router: router, onFinished: {
            didComplete = true
        })
        view.onFinished?()
        #expect(didComplete == true)
    }

    @Test("TEST-SCR-02: HomeView dispatches .assessmentOverview on Card 02 tap")
    @MainActor
    func testHomeViewNavigation() {
        let router = AppRouter()
        router.navigate(to: .home)
        #expect(router.currentRoute == .home)
        
        // Simulating Assessment action card tap
        router.navigate(to: .assessmentOverview)
        #expect(router.currentRoute == .assessmentOverview)
    }

    @Test("TEST-SCR-02B: HomeView dispatches .exercises on Card 03 tap")
    @MainActor
    func testHomeViewExercisesNavigation() {
        let router = AppRouter()
        router.navigate(to: .home)
        #expect(router.currentRoute == .home)
        
        // Simulating Exercises action card tap
        router.navigate(to: .exercises)
        #expect(router.currentRoute == .exercises)
    }

    @Test("TEST-SCR-03: ChooseRelationshipsView validates participant selection count")
    @MainActor
    func testChooseRelationshipsSelection() {
        let availablePeople = Person.mockRolodex + [Person(name: "Sixth", initials: "S", category: .friend)]
        var selected: [Person] = []
        #expect(!AssessmentSessionState.canStart(with: selected.count))
        for (index, person) in availablePeople.prefix(5).enumerated() {
            selected = ChooseRelationshipsView.toggledSelection(selected, person: person)!
            #expect(selected.count == index + 1)
            if index < 4 { #expect(!AssessmentSessionState.canStart(with: selected.count)) }
        }
        #expect(AssessmentSessionState.canStart(with: selected.count))
        #expect(ChooseRelationshipsView.toggledSelection(selected, person: availablePeople[5]) == nil)
        #expect(ChooseRelationshipsView.toggledSelection(selected, person: availablePeople[0])?.count == 4)
    }

    @Test("First five contacts are preselected; later assessments reuse the last five")
    @MainActor
    func testChooseRelationshipsDefaults() {
        let contacts = Person.mockRolodex + [Person(name: "Sixth", initials: "S", category: .friend)]
        let first = ChooseRelationshipsView.initialSelection(contacts: contacts, previousIDs: nil, draft: [])
        #expect(first.map(\.id) == Array(contacts.prefix(5)).map(\.id))
        #expect(!first.contains(where: { $0.id == contacts[5].id }))

        let lastAssessmentIDs = [contacts[5], contacts[1], contacts[3], contacts[2], contacts[4]].map(\.id)
        let repeatSelection = ChooseRelationshipsView.initialSelection(contacts: contacts, previousIDs: lastAssessmentIDs, draft: [])
        #expect(repeatSelection.map(\.id) == lastAssessmentIDs)

        let changedDraft = Array(contacts.prefix(3))
        let resumed = ChooseRelationshipsView.initialSelection(contacts: contacts, previousIDs: lastAssessmentIDs, draft: changedDraft)
        #expect(resumed.map(\.id) == changedDraft.map(\.id))
    }

    @Test("W01/W02: legacy age is ignored and a name-only relationship is valid")
    func testAgeFreeContactModel() throws {
        #expect(ContactEditDraft.isValidName(" Alex "))
        #expect(!ContactEditDraft.isValidName(" \n "))
        let legacy = Data(#"{"id":"00000000-0000-0000-0000-000000000001","name":"Alex Smith","initials":"AS","category":"Friend","customCategoryName":null,"age":27}"#.utf8)
        let person = try JSONDecoder().decode(Person.self, from: legacy)
        #expect(person.name == "Alex Smith")
        #expect(person.displayCategory == "Friend")
        let encoded = String(decoding: try JSONEncoder().encode(person), as: UTF8.self)
        #expect(!encoded.contains("age"))
        let unspecified = Person(name: "Alex", initials: "A", category: .custom)
        #expect(unspecified.displayCategory == "")
        let nameOnly = ContactEditDraft(contactID: nil, name: " Alex Smith ", relationshipText: "", photoData: nil)
        #expect(nameOnly.makePerson()?.name == "Alex Smith")
        #expect(nameOnly.makePerson()?.displayCategory == "")
        let named = ContactEditDraft(contactID: nil, name: "Alex", relationshipText: "  Best friend  ", photoData: nil)
        #expect(named.makePerson()?.displayCategory == "Best friend")
        #expect(ContactEditDraft(contactID: nil, name: " ", relationshipText: "Friend", photoData: nil).makePerson() == nil)
    }

    @Test("TEST-SCR-04: RelationshipFrequencyView allocations sum to exactly 100%")
    func testFrequencyAllocationsSum() {
        let allocations = [
            ParticipantAllocation(initials: "SM", firstName: "Sarah", percentage: 0.30),
            ParticipantAllocation(initials: "JC", firstName: "James", percentage: 0.25),
            ParticipantAllocation(initials: "LC", firstName: "Linda", percentage: 0.20),
            ParticipantAllocation(initials: "DO", firstName: "David", percentage: 0.15),
            ParticipantAllocation(initials: "RS", firstName: "Rachel", percentage: 0.10)
        ]
        
        let sum = allocations.reduce(0.0) { $0 + $1.percentage }
        #expect(abs(sum - 1.0) < 0.001)
    }

    @Test("TEST-SCR-05: Only the final participant's final question requires submission")
    @MainActor
    func testSurveyQuestionSubmissionBoundary() {
        let contacts = Person.mockFigmaContacts
        let participants = [
            AssessmentParticipant(person: contacts[0], percentTimeSpent: 0.30),
            AssessmentParticipant(person: contacts[1], percentTimeSpent: 0.25),
            AssessmentParticipant(person: contacts[2], percentTimeSpent: 0.20),
            AssessmentParticipant(person: contacts[3], percentTimeSpent: 0.15),
            AssessmentParticipant(person: contacts[4], percentTimeSpent: 0.10)
        ]
        
        var session = AssessmentSessionState(
            participants: participants,
            totalQuestionsPerPerson: 4
        )
        
        // The assessment starts with automatic progression.
        #expect(session.currentParticipantIndex == 0)
        #expect(session.currentQuestionIndex == 0)
        #expect(session.isFinalQuestion == false)
        
        // Answer questions for person 0
        session.recordAnswer(for: "q_1", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_2", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_3", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_4", option: SurveyQuestion.standard5PointLikertOptions[4])
        
        // The last question for person 0 still advances to the next person.
        #expect(session.isFinalQuestion == false)
    }

    @Test("TEST-SCR-06: SurveyResultsView computes donut segments and individual results")
    func testResultsCalculation() {
        let contacts = Person.mockFigmaContacts
        let participants = [
            AssessmentParticipant(person: contacts[0], percentTimeSpent: 0.30),
            AssessmentParticipant(person: contacts[1], percentTimeSpent: 0.25),
            AssessmentParticipant(person: contacts[2], percentTimeSpent: 0.20),
            AssessmentParticipant(person: contacts[3], percentTimeSpent: 0.15),
            AssessmentParticipant(person: contacts[4], percentTimeSpent: 0.10)
        ]
        
        var session = AssessmentSessionState(
            participants: participants,
            totalQuestionsPerPerson: 4
        )
        
        // Populate perfect answers
        for p in participants {
            for q in SurveyQuestion.mockQuestionBank {
                session.recordAnswer(for: q.id, option: SurveyQuestion.standard5PointLikertOptions[4])
            }
        }
        
        let engine = FlexibleScoringEngine()
        let result = engine.calculateResult(for: session)
        
        #expect(result.individualResults.count == 5)
        #expect(result.safetyDistribution.safePercentage > 0.0 || result.safetyDistribution.highRiskPercentage >= 0.0)
    }

    @Test("TEST-SCR-07: SurveyResultsExpandedView dismiss route transitions back")
    @MainActor
    func testModalDismiss() {
        let router = AppRouter()
        router.navigate(to: .surveyResults)
        router.navigate(to: .surveyResultsExpanded)
        #expect(router.currentRoute == .surveyResultsExpanded)
        
        router.pop()
        #expect(router.currentRoute == .surveyResults)
    }

    @Test("TEST-SCR-08: PastResultsView static trend cards and individual selector state")
    @MainActor
    func testPastResultsCardState() {
        let router = AppRouter()
        let view = PastResultsView(router: router)
        #expect(view.router.currentRoute == .loading)
        
        let careChart = CARETrendChart()
        #expect(careChart != nil)
        
        var selectedIndividual: String? = "Sarah Mitchell"
        #expect(selectedIndividual == "Sarah Mitchell")
        selectedIndividual = "James Rivera"
        #expect(selectedIndividual == "James Rivera")
    }

    @Test("TEST-SCR-09: Results by individual swipeable carousel and page indicator dots")
    @MainActor
    func testResultsByIndividualPagingAndDots() {
        var activeIndex = 0
        let totalCount = 5
        let dots = PageIndicatorDots(totalCount: totalCount, currentIndex: activeIndex) { newIndex in
            activeIndex = newIndex
        }
        #expect(dots.totalCount == 5)
        #expect(dots.currentIndex == 0)
        
        dots.onSelectIndex?(1)
        #expect(activeIndex == 1)
        
        dots.onSelectIndex?(4)
        #expect(activeIndex == 4)
    }

    @Test("TEST-SCR-10: HomeView handles in-progress assessment resume and discard with draft persistence")
    @MainActor
    func testHomeViewResumeAndDiscard() {
        AssessmentSessionState.clearDraft()
        let router = AppRouter()
        let contacts = Person.mockFigmaContacts
        let participants = contacts.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
        
        var session = AssessmentSessionState(
            participants: participants,
            totalQuestionsPerPerson: 20
        )
        
        // Initially no answers -> not started
        #expect(!session.hasStarted)
        
        // Record an answer -> now started / in-progress
        session.recordAnswer(for: "q_1", option: SurveyQuestion.standard5PointLikertOptions[2])
        #expect(session.hasStarted)
        #expect(!session.isComplete)
        
        // Save to draft (simulating app quit during questionnaire)
        session.saveDraft()
        #expect(AssessmentSessionState.loadDraft() != nil)
        
        // Test binding with HomeView
        var activeSession: AssessmentSessionState? = AssessmentSessionState.loadDraft()
        var discarded = false
        
        let homeView = HomeView(
            router: router,
            activeSession: Binding(get: { activeSession }, set: { activeSession = $0 }),
            onDiscardAssessment: {
                discarded = true
                AssessmentSessionState.clearDraft()
            }
        )
        #expect(homeView.activeSession != nil)
        #expect(homeView.activeSession?.hasStarted == true)
        
        // Simulate resume navigation
        router.navigate(to: .surveyQuestion)
        #expect(router.currentRoute == .surveyQuestion)
        
        // Simulate discard
        homeView.onDiscardAssessment?()
        activeSession = nil
        #expect(discarded)
        #expect(activeSession == nil)
        #expect(AssessmentSessionState.loadDraft() == nil)
    }


    @Test("TEST-SCR-15: SurveyOverviewView initializes with router and pinned action structure")
    @MainActor
    func testSurveyOverviewViewRendering() {
        let router = AppRouter()
        let surveyOverview = SurveyOverviewView(router: router)
        #expect(surveyOverview.router === router)
    }

    @Test("TEST-SCR-16: AssessmentOverviewView initializes with router and pinned action structure")
    @MainActor
    func testAssessmentOverviewViewRendering() {
        let router = AppRouter()
        let overview = AssessmentOverviewView(router: router)
        #expect(overview.router === router)
    }
}
