import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 2: Assessment Session & Multi-Person Progression Test Suite")
struct AssessmentSessionTests {
    
    @Test("TEST-SES-01: Progress ratio increases monotonically across questionnaire steps when answered")
    func testMonotonicProgressRatio() {
        let p1 = Person(name: "P1", initials: "P1", category: .partner, age: 30)
        let p2 = Person(name: "P2", initials: "P2", category: .friend, age: 25)
        let participants = [AssessmentParticipant(person: p1), AssessmentParticipant(person: p2)]
        let opt = SurveyOption(id: "opt_1", text: "Option A", rawScoreValue: 1.0)
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 2)
        
        #expect(session.progressRatio == 0.0)
        #expect(session.canAdvance == false)
        
        // Cannot advance without answer
        let prematureAdvance = session.advance()
        #expect(prematureAdvance == false)
        #expect(session.progressRatio == 0.0)
        
        // Answer P1 Q1 and advance -> P1 Q2
        session.recordAnswer(for: "q_1", option: opt)
        #expect(session.canAdvance == true)
        let advanced1 = session.advance()
        #expect(advanced1 == true)
        #expect(session.progressRatio == 0.25)
        
        // Answer P1 Q2 and advance -> P2 Q1
        session.recordAnswer(for: "q_2", option: opt)
        let advanced2 = session.advance()
        #expect(advanced2 == true)
        #expect(session.progressRatio == 0.50)
        
        // Answer P2 Q1 and advance -> P2 Q2
        session.recordAnswer(for: "q_1", option: opt)
        let advanced3 = session.advance()
        #expect(advanced3 == true)
        #expect(session.progressRatio == 0.75)
        
        // Answer P2 Q2 (Final step) and attempt advance beyond last step
        session.recordAnswer(for: "q_2", option: opt)
        #expect(session.isComplete == true)
        let advancedLast = session.advance()
        #expect(advancedLast == false)
    }

    @Test("TEST-SES-02: Mutating/updating a recorded answer overwrites in place without duplicating records")
    func testInPlaceAnswerMutation() {
        let p1 = Person(name: "P1", initials: "P1", category: .partner, age: 30)
        let participant = AssessmentParticipant(person: p1)
        var session = AssessmentSessionState(participants: [participant], totalQuestionsPerPerson: 2)
        
        let opt1 = SurveyOption(id: "opt_1", text: "Option A", rawScoreValue: 0.4)
        let opt2 = SurveyOption(id: "opt_2", text: "Option B (Revised)", rawScoreValue: 0.8)
        
        session.recordAnswer(for: "q_1", option: opt1)
        #expect(session.recordedAnswers[p1.id]?["q_1"]?.id == "opt_1")
        #expect(session.recordedAnswers[p1.id]?.count == 1)
        
        // Mutate answer for q_1
        session.recordAnswer(for: "q_1", option: opt2)
        #expect(session.recordedAnswers[p1.id]?["q_1"]?.id == "opt_2")
        #expect(session.recordedAnswers[p1.id]?.count == 1)
    }

    @Test("TEST-SES-03: Multi-person progression correctly updates button titles across all 5 participant boundaries")
    func testMultiPersonButtonTitles() {
        let contacts = Person.mockFigmaContacts // 5 people
        let participants = contacts.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
        let opt = SurveyOption(id: "opt_1", text: "Option A", rawScoreValue: 1.0)
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 4)
        
        // Person 1 (Sarah Mitchell) Q1-Q3 -> "Next"
        #expect(session.currentButtonTitle == "Next")
        session.currentQuestionIndex = 1
        #expect(session.currentButtonTitle == "Next")
        session.currentQuestionIndex = 2
        #expect(session.currentButtonTitle == "Next")
        
        // Person 1 Q4 -> "Next: James Cooper"
        session.currentQuestionIndex = 3
        #expect(session.currentButtonTitle == "Next: James Cooper")
        
        // Advance to Person 2 (James Cooper)
        session.recordAnswer(for: "q_4", option: opt)
        let _ = session.advance()
        #expect(session.currentParticipantIndex == 1)
        #expect(session.currentQuestionIndex == 0)
        #expect(session.currentButtonTitle == "Next")
        
        // Person 2 Q4 -> "Next: Linda Chen"
        session.currentQuestionIndex = 3
        #expect(session.currentButtonTitle == "Next: Linda Chen")
        
        // Advance to Person 5 (Rachel Stein - Final Person)
        session.currentParticipantIndex = 4
        session.currentQuestionIndex = 3
        #expect(session.currentButtonTitle == "Complete Assessment")
    }

    @Test("TEST-SES-04: Person rolodex initializes with Figma defaults")
    func testPersonRolodexDefaults() {
        let contacts = Person.mockFigmaContacts
        #expect(contacts.count == 5)
        #expect(contacts[0].name == "Sarah Mitchell")
        #expect(contacts[1].name == "James Cooper")
        #expect(contacts[2].name == "Linda Chen")
        #expect(contacts[3].name == "David Okafor")
        #expect(contacts[4].name == "Rachel Stein")
    }

    @Test("TEST-SES-05: Strict answer requirement blocks progression until question is answered")
    func testStrictAnswerRequirement() {
        let p1 = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let participant = AssessmentParticipant(person: p1)
        var session = AssessmentSessionState(participants: [participant], totalQuestionsPerPerson: 3)
        let opt = SurveyOption(id: "opt_1", text: "Completely grounded", rawScoreValue: 1.0)
        
        // Question 1 initial state (unanswered)
        #expect(session.currentQuestionIndex == 0)
        #expect(session.hasAnswerForCurrentQuestion == false)
        #expect(session.canAdvance == false)
        
        // Attempting to advance must fail
        #expect(session.advance() == false)
        #expect(session.currentQuestionIndex == 0)
        
        // Record answer for Question 1
        session.recordAnswer(for: "q_1", option: opt)
        #expect(session.hasAnswerForCurrentQuestion == true)
        #expect(session.canAdvance == true)
        
        // Now advance succeeds and moves to Question 2
        #expect(session.advance() == true)
        #expect(session.currentQuestionIndex == 1)
        
        // Question 2 is now unanswered
        #expect(session.hasAnswerForCurrentQuestion == false)
        #expect(session.canAdvance == false)
        #expect(session.advance() == false)
    }
}
