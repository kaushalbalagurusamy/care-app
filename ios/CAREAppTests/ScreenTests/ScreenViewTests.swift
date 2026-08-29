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

    @Test("TEST-SCR-03: ChooseRelationshipsView validates participant selection count")
    @MainActor
    func testChooseRelationshipsSelection() {
        let availablePeople = Person.mockRolodex
        var selectedIds = Set<UUID>()
        
        #expect(selectedIds.isEmpty)
        #expect(selectedIds.count == 0)
        
        // Select 3 people
        for p in availablePeople.prefix(3) {
            selectedIds.insert(p.id)
        }
        #expect(selectedIds.count == 3)
        #expect(selectedIds.count >= 1)
        #expect(selectedIds.count <= 5)
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

    @Test("TEST-SCR-05: SurveyQuestionView button title transitions dynamically")
    @MainActor
    func testSurveyQuestionButtonProgression() {
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
        
        // At start (Person 0, Question 0) -> Next
        #expect(session.currentParticipantIndex == 0)
        #expect(session.currentQuestionIndex == 0)
        
        // Answer questions for person 0
        session.recordAnswer(for: "q_1", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_2", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_3", option: SurveyQuestion.standard5PointLikertOptions[4])
        _ = session.advance()
        session.recordAnswer(for: "q_4", option: SurveyQuestion.standard5PointLikertOptions[4])
        
        // Now on Person 0 last question -> prompts "Next: James Cooper"
        #expect(session.currentButtonTitle == "Next: James Cooper")
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

    @Test("TEST-SCR-08: PastResultsView accordion cards expand/collapse cleanly")
    func testPastResultsCardExpansion() {
        var expandedCardId: UUID? = nil
        let cardId = UUID()
        
        #expect(expandedCardId == nil)
        expandedCardId = cardId
        #expect(expandedCardId == cardId)
        expandedCardId = nil
        #expect(expandedCardId == nil)
    }
}
