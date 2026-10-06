import Testing
import Foundation
import SwiftData
@testable import CAREApp

@Suite("Phase 2: Assessment Session & Multi-Person Progression Test Suite")
struct AssessmentSessionTests {

    @Test("Discarded assessment and selection do not reappear after store reopening")
    @MainActor
    func testDurableAssessmentDiscard() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let store = try UserDraftStore(container: container)
        let session = AssessmentSessionState(participants: Person.mockFigmaContacts.map { AssessmentParticipant(person: $0) })
        try store.saveValue(session, key: "assessment-draft")
        try store.saveValue(Person.mockFigmaContacts, key: "assessment-selection")
        try store.saveValue([ParticipantAllocation](), key: "assessment-allocations")
        try store.discardAssessmentDraft()
        let reopened = try UserDraftStore(container: container)
        #expect(try reopened.loadValue(AssessmentSessionState.self, key: "assessment-draft") == nil)
        #expect(try reopened.loadValue([Person].self, key: "assessment-selection") == nil)
        #expect(try reopened.loadValue([ParticipantAllocation].self, key: "assessment-allocations") == nil)
    }

    @Test("Assessment Back follows saved question position, including participant boundaries")
    func testPreviousAssessmentStepAfterResume() throws {
        let participants = Person.mockFigmaContacts.map { AssessmentParticipant(person: $0) }
        let first = SurveyQuestion.full20QuestionBank[0].options[0]
        let last = SurveyQuestion.full20QuestionBank[19].options[1]
        var session = AssessmentSessionState(participants: participants)
        let beforeFirst = session.moveToPreviousQuestion()
        #expect(!beforeFirst)
        session.recordAnswer(for: "q_1", option: first)
        let advanced = session.advance()
        #expect(advanced)
        let movedBack = session.moveToPreviousQuestion()
        #expect(movedBack)
        #expect(session.currentAnswer?.id == first.id)
        #expect(session.currentQuestionIndex == 0)
        session.currentParticipantIndex = 1
        session.currentQuestionIndex = 0
        session.recordedAnswers[participants[0].id, default: [:]]["q_20"] = last
        let resumed = try JSONDecoder().decode(AssessmentSessionState.self, from: JSONEncoder().encode(session))
        var moved = resumed
        let crossedBoundary = moved.moveToPreviousQuestion()
        #expect(crossedBoundary)
        #expect(moved.currentParticipantIndex == 0)
        #expect(moved.currentQuestionIndex == 19)
        #expect(moved.currentAnswer?.id == last.id)
    }

    @Test("Submission requires exactly five distinct people and every answer")
    func testFullSubmissionValidation() {
        let people = Person.mockFigmaContacts
        let participants = people.map { AssessmentParticipant(person: $0) }
        let questions = SurveyQuestion.full20QuestionBank
        var session = AssessmentSessionState(participants: participants)
        #expect(!session.isFullyAnswered)
        for person in people {
            for question in questions { session.recordedAnswers[person.id, default: [:]][question.id] = question.options[0] }
        }
        #expect(session.isFullyAnswered)
        session.recordedAnswers[people[0].id]?[questions[0].id] = SurveyOption(
            id: questions[0].options[0].id, text: "Older wording", rawScoreValue: questions[0].options[0].rawScoreValue
        )
        #expect(session.isFullyAnswered)
        session.recordedAnswers[people[0].id]?[questions[0].id] = SurveyOption(id: "tampered", text: "tampered", rawScoreValue: 50)
        #expect(!session.isFullyAnswered)
        session.recordedAnswers[people[0].id]?[questions[0].id] = questions[0].options[0]
        session.recordedAnswers[people[0].id]?["unknown"] = questions[0].options[0]
        #expect(!session.isFullyAnswered)
        session.recordedAnswers[people[0].id]?.removeValue(forKey: "unknown")
        #expect(session.isFullyAnswered)
        session.recordedAnswers[people[0].id]?.removeValue(forKey: questions[0].id)
        #expect(!session.isFullyAnswered)
        session.participants[4] = participants[0]
        #expect(!session.isFullyAnswered)
    }
    
    @Test("TEST-SES-01: Progress ratio increases monotonically across questionnaire steps when answered")
    func testMonotonicProgressRatio() {
        let p1 = Person(name: "P1", initials: "P1", category: .partner)
        let p2 = Person(name: "P2", initials: "P2", category: .friend)
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
        let p1 = Person(name: "P1", initials: "P1", category: .partner)
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

    @Test("TEST-SES-03: Submit is reserved for the final question of the final participant")
    func testFinalSubmissionBoundary() {
        let contacts = Person.mockFigmaContacts // 5 people
        let participants = contacts.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
        let opt = SurveyOption(id: "opt_1", text: "Option A", rawScoreValue: 1.0)
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 4)
        
        // No question for an earlier participant needs a Submit button.
        #expect(session.isFinalQuestion == false)
        session.currentQuestionIndex = 1
        #expect(session.isFinalQuestion == false)
        session.currentQuestionIndex = 2
        #expect(session.isFinalQuestion == false)
        
        // The last question for person 1 still advances automatically.
        session.currentQuestionIndex = 3
        #expect(session.isFinalQuestion == false)
        
        // Advance to Person 2 (James Cooper)
        session.recordAnswer(for: "q_4", option: opt)
        let _ = session.advance()
        #expect(session.currentParticipantIndex == 1)
        #expect(session.currentQuestionIndex == 0)
        #expect(session.isFinalQuestion == false)
        
        // The last question for person 2 is not the assessment's last question.
        session.currentQuestionIndex = 3
        #expect(session.isFinalQuestion == false)
        
        // Advance to Person 5 (Rachel Stein - Final Person)
        session.currentParticipantIndex = 4
        session.currentQuestionIndex = 2
        #expect(session.isFinalQuestion == false)
        session.currentQuestionIndex = 3
        #expect(session.isFinalQuestion == true)
        #expect(session.isComplete == false)
        session.recordAnswer(for: "q_4", option: opt)
        #expect(session.isComplete == true)
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
        let p1 = Person(name: "Sarah Mitchell", initials: "SM", category: .partner)
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

    @Test("TEST-SES-05: AssessmentSessionState draft persistence and restoration")
    func testDraftPersistenceAndRestoration() {
        AssessmentSessionState.clearDraft()
        #expect(AssessmentSessionState.loadDraft() == nil)
        
        let p1 = Person(name: "Test Participant", initials: "TP", category: .friend)
        let participants = [p1, Person(name: "Second", initials: "SE", category: .friend), Person(name: "Third", initials: "TH", category: .friend), Person(name: "Fourth", initials: "FO", category: .friend), Person(name: "Fifth", initials: "FI", category: .friend)].map { AssessmentParticipant(person: $0) }
        let opt = SurveyOption(id: "opt_3", text: "Neutral", rawScoreValue: 0.5)
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 20)
        session.recordAnswer(for: "q_1", option: opt)
        #expect(session.hasStarted == true)
        
        // Save draft
        session.saveDraft()
        
        // Load draft from storage
        let loaded = AssessmentSessionState.loadDraft()
        #expect(loaded != nil)
        #expect(loaded?.participants.count == 5)
        #expect(loaded?.participants[0].person.name == "Test Participant")
        #expect(loaded?.recordedAnswers[p1.id]?["q_1"]?.id == "opt_3")
        
        // Clear draft
        AssessmentSessionState.clearDraft()
        #expect(AssessmentSessionState.loadDraft() == nil)
    }
}
