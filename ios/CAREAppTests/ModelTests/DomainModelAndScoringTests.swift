import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 2: Domain Models & Pluggable Scoring Test Suite")
struct DomainModelAndScoringTests {
    
    @Test("TEST-MOD-01: Multi-domain SurveyQuestion JSON decoding verification")
    func testMultiDomainQuestionDecoding() throws {
        let json = """
        {
            "id": "q_1",
            "prompt": "How settled do you feel in their presence?",
            "targetDomains": [
                {"domain": "calm", "weightMultiplier": 1.0},
                {"domain": "resonant", "weightMultiplier": 0.5}
            ],
            "options": [
                {"id": "opt_1", "text": "Completely grounded", "rawScoreValue": 1.0},
                {"id": "opt_2", "text": "Constantly on edge", "rawScoreValue": 0.2}
            ]
        }
        """.data(using: .utf8)!
        
        let question = try JSONDecoder().decode(SurveyQuestion.self, from: json)
        #expect(question.id == "q_1")
        #expect(question.targetDomains.count == 2)
        #expect(question.targetDomains[0].domain == .calm)
        #expect(question.targetDomains[0].weightMultiplier == 1.0)
        #expect(question.targetDomains[1].domain == .resonant)
        #expect(question.targetDomains[1].weightMultiplier == 0.5)
        #expect(question.options.count == 2)
    }

    @Test("TEST-MOD-02: FlexibleScoringEngine calculates frequency-weighted distributions")
    func testFlexibleScoringCalculations() {
        let personA = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let personB = Person(name: "James Cooper", initials: "JC", category: .friend, age: 28)
        
        let participants = [
            AssessmentParticipant(person: personA, percentTimeSpent: 0.60),
            AssessmentParticipant(person: personB, percentTimeSpent: 0.40)
        ]
        
        let optHigh = SurveyOption(id: "opt_5", text: "Grounded", rawScoreValue: 1.0) // 100%
        let optLow = SurveyOption(id: "opt_1", text: "Tense", rawScoreValue: 0.2)     // 20%
        
        let recordedAnswers: [UUID: [String: SurveyOption]] = [
            personA.id: ["q_1": optHigh, "q_2": optHigh],
            personB.id: ["q_1": optLow, "q_2": optLow]
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: participants,
            recordedAnswers: recordedAnswers,
            questions: SurveyQuestion.mockQuestionBank
        )
        
        #expect(result.individualResults.count == 2)
        #expect(result.individualResults[0].safetyTier == .healthy)
        #expect(result.individualResults[0].normalizedScore == 100.0)
        #expect(result.individualResults[1].safetyTier == .highRisk)
        #expect(result.individualResults[1].normalizedScore == 20.0)
        
        // Distribution weighting: Person A (60%) Safe, Person B (40%) High Risk
        #expect(result.safetyDistribution.safePercentage == 0.60)
        #expect(result.safetyDistribution.highRiskPercentage == 0.40)
        #expect(result.safetyDistribution.moderatePercentage == 0.0)
    }

    @Test("TEST-MOD-03: Multi-person progression vends dynamic button titles")
    func testDynamicButtonTitleProgression() {
        let person1 = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let person2 = Person(name: "James Cooper", initials: "JC", category: .friend, age: 28)
        let participants = [
            AssessmentParticipant(person: person1, percentTimeSpent: 0.5),
            AssessmentParticipant(person: person2, percentTimeSpent: 0.5)
        ]
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 4)
        
        // Question 1 for Person 1
        #expect(session.currentButtonTitle == "Next")
        
        // Advance to Question 4 (last question for Person 1)
        session.currentQuestionIndex = 3
        #expect(session.currentButtonTitle == "Next: James Cooper")
        
        // Advance to Person 2, Question 4 (Final question overall)
        session.currentParticipantIndex = 1
        session.currentQuestionIndex = 3
        #expect(session.currentButtonTitle == "Complete Assessment")
    }

    @Test("TEST-MOD-04: Person rolodex initializes with Figma defaults")
    func testPersonRolodexInitialization() {
        let contacts = Person.mockFigmaContacts
        #expect(contacts.count == 5)
        #expect(contacts[0].name == "Sarah Mitchell")
        #expect(contacts[0].category == .partner)
        #expect(contacts[1].name == "James Cooper")
        #expect(contacts[1].category == .friend)
    }

    @Test("TEST-NAV-01: AppRouter manages NavigationPath state deterministically")
    @MainActor
    func testAppRouterNavigationFlow() {
        let router = AppRouter()
        #expect(router.path.isEmpty)
        
        router.navigate(to: .assessmentOverview)
        #expect(router.path.count == 1)
        
        router.navigate(to: .surveyOverview)
        #expect(router.path.count == 2)
        
        router.pop()
        #expect(router.path.count == 1)
        
        router.navigate(to: .education)
        router.navigate(to: .exercises)
        #expect(router.path.count == 3)
        
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
}
