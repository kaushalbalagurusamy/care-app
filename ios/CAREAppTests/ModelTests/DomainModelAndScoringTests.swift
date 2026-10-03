import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 2: Domain Models & Pluggable Scoring Test Suite")
struct DomainModelAndScoringTests {
    
    @Test("TEST-MOD-01: Multi-domain SurveyQuestion JSON decoding contract verification")
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

    @Test("TEST-MOD-02A: Scoring engine calculates 100% Safe when all answers are maximum (1.0)")
    func testScoringAllMaximumSafeScores() {
        let person = Person(name: "Sarah Mitchell", initials: "SM", category: .partner)
        let participant = AssessmentParticipant(person: person, percentTimeSpent: 1.0)
        let optMax = SurveyOption(id: "opt_5", text: "Max Grounded", rawScoreValue: 1.0)
        
        let recordedAnswers: [UUID: [String: SurveyOption]] = [
            person.id: [
                "q_1": optMax,
                "q_2": optMax,
                "q_3": optMax,
                "q_4": optMax
            ]
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: [participant],
            recordedAnswers: recordedAnswers,
            questions: SurveyQuestion.mockQuestionBank
        )
        
        #expect(result.individualResults.count == 1)
        #expect(result.individualResults[0].normalizedScore == 100.0)
        #expect(result.individualResults[0].safetyTier == .healthy)
        #expect(result.safetyDistribution.safePercentage == 1.0)
        #expect(result.safetyDistribution.moderatePercentage == 0.0)
        #expect(result.safetyDistribution.highRiskPercentage == 0.0)
    }

    @Test("TEST-MOD-02B: Scoring engine calculates 100% High Risk when all answers are minimum (0.2)")
    func testScoringAllMinimumHighRiskScores() {
        let person = Person(name: "Linda Chen", initials: "LC", category: .coworker)
        let participant = AssessmentParticipant(person: person, percentTimeSpent: 1.0)
        let optMin = SurveyOption(id: "opt_1", text: "Tense/Anxious", rawScoreValue: 0.20)
        
        let recordedAnswers: [UUID: [String: SurveyOption]] = [
            person.id: [
                "q_1": optMin,
                "q_2": optMin,
                "q_3": optMin,
                "q_4": optMin
            ]
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: [participant],
            recordedAnswers: recordedAnswers,
            questions: SurveyQuestion.mockQuestionBank
        )
        
        #expect(result.individualResults.count == 1)
        #expect(result.individualResults[0].normalizedScore == 20.0)
        #expect(result.individualResults[0].safetyTier == .highRisk)
        #expect(result.safetyDistribution.safePercentage == 0.0)
        #expect(result.safetyDistribution.highRiskPercentage == 1.0)
    }

    @Test("TEST-MOD-02C: Clinical cutoff thresholds strictly partition Safe (>=75), Moderate (60-74), and High (<60)")
    func testScoringExactCutoffThresholds() {
        let config = ScoringConfiguration(safeScoreCutoff: 75.0, moderateScoreCutoff: 60.0)
        
        // Exact 75.0 -> Healthy/Safe
        let p75 = Person(name: "P75", initials: "P1", category: .friend)
        let part75 = AssessmentParticipant(person: p75, percentTimeSpent: 0.25)
        let opt75 = SurveyOption(id: "o75", text: "75%", rawScoreValue: 0.75)
        
        // Exact 74.0 -> Moderate
        let p74 = Person(name: "P74", initials: "P2", category: .friend)
        let part74 = AssessmentParticipant(person: p74, percentTimeSpent: 0.25)
        let opt74 = SurveyOption(id: "o74", text: "74%", rawScoreValue: 0.74)
        
        // Exact 60.0 -> Moderate
        let p60 = Person(name: "P60", initials: "P3", category: .friend)
        let part60 = AssessmentParticipant(person: p60, percentTimeSpent: 0.25)
        let opt60 = SurveyOption(id: "o60", text: "60%", rawScoreValue: 0.60)
        
        // Exact 59.0 -> High Risk
        let p59 = Person(name: "P59", initials: "P4", category: .friend)
        let part59 = AssessmentParticipant(person: p59, percentTimeSpent: 0.25)
        let opt59 = SurveyOption(id: "o59", text: "59%", rawScoreValue: 0.59)
        
        let answers: [UUID: [String: SurveyOption]] = [
            p75.id: ["q_1": opt75],
            p74.id: ["q_1": opt74],
            p60.id: ["q_1": opt60],
            p59.id: ["q_1": opt59]
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: [part75, part74, part60, part59],
            recordedAnswers: answers,
            questions: SurveyQuestion.mockQuestionBank,
            config: config
        )
        
        #expect(result.individualResults[0].safetyTier == .healthy, "Score 75.0 must be Healthy/Safe")
        #expect(result.individualResults[1].safetyTier == .moderate, "Score 74.0 must be Moderate")
        #expect(result.individualResults[2].safetyTier == .moderate, "Score 60.0 must be Moderate")
        #expect(result.individualResults[3].safetyTier == .highRisk, "Score 59.0 must be High Risk")
    }

    @Test("TEST-MOD-02D: Scoring engine gracefully handles empty answers without NaN or crashes")
    func testScoringEmptyAnswersFallback() {
        let person = Person(name: "Sarah Mitchell", initials: "SM", category: .partner)
        let participant = AssessmentParticipant(person: person, percentTimeSpent: 1.0)
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: [participant],
            recordedAnswers: [:],
            questions: []
        )
        
        #expect(!result.individualResults.isEmpty)
        #expect(result.individualResults[0].normalizedScore.isFinite)
        #expect(!result.individualResults[0].normalizedScore.isNaN)
        #expect(result.safetyDistribution.safePercentage >= 0.0)
    }

    @Test("TEST-MOD-02E: Frequency-weighted distribution normalizes skewed participant weights accurately")
    func testFrequencyWeightedDistribution() {
        let personA = Person(name: "Partner", initials: "P", category: .partner)
        let personB = Person(name: "Coworker", initials: "C", category: .coworker)
        
        // 80% time with high-risk person, 20% time with safe person
        let participants = [
            AssessmentParticipant(person: personA, percentTimeSpent: 0.20),
            AssessmentParticipant(person: personB, percentTimeSpent: 0.80)
        ]
        
        let optSafe = SurveyOption(id: "s", text: "Safe", rawScoreValue: 1.0) // 100%
        let optHighRisk = SurveyOption(id: "h", text: "High", rawScoreValue: 0.2) // 20%
        
        let answers: [UUID: [String: SurveyOption]] = [
            personA.id: ["q_1": optSafe],
            personB.id: ["q_1": optHighRisk]
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(
            participants: participants,
            recordedAnswers: answers,
            questions: SurveyQuestion.mockQuestionBank
        )
        
        #expect(result.safetyDistribution.safePercentage == 0.20)
        #expect(result.safetyDistribution.highRiskPercentage == 0.80)
        #expect(result.safetyDistribution.moderatePercentage == 0.0)
    }

    @Test("Five people answering all 20 questions at maximum produce 125 points per C.A.R.E. category")
    func testTwentyQuestionCategoryMaximum() {
        let people = Array(Person.mockFigmaContacts.prefix(5))
        let participants = people.map { AssessmentParticipant(person: $0, percentTimeSpent: 0.20) }
        let answers = Dictionary(uniqueKeysWithValues: people.map { person in
            (person.id, Dictionary(uniqueKeysWithValues: SurveyQuestion.full20QuestionBank.map { question in
                (question.id, question.options.last!)
            }))
        })

        let result = FlexibleScoringEngine().calculateResult(
            for: AssessmentSessionState(
                participants: participants,
                recordedAnswers: answers
            )
        )

        for domain in CAREDomain.allCases {
            #expect(abs((result.domainScores[domain]?.earnedPoints ?? 0) - 125) < 0.001)
            #expect(result.domainScores[domain]?.maxPossiblePoints == 125)
        }
        #expect(ResultsV2Metrics.totalScore(result) == 500)
    }

    @Test("Exactly five distinct relationships are required to begin an assessment")
    func testRequiredRelationshipCount() {
        #expect(!AssessmentSessionState.canStart(with: 0))
        #expect(!AssessmentSessionState.canStart(with: 4))
        #expect(AssessmentSessionState.canStart(with: 5))
        #expect(!AssessmentSessionState.canStart(with: 6))
    }

    @Test("Category totals sum raw points independently of relationship time shares")
    func testCategoryRawPointsIgnoreTimeAllocation() {
        let people = Array(Person.mockFigmaContacts.prefix(5))
        let participants = people.enumerated().map { index, person in
            AssessmentParticipant(person: person, percentTimeSpent: index == 0 ? 0.80 : 0.05)
        }
        let questions = SurveyQuestion.full20QuestionBank
        let answers = Dictionary(uniqueKeysWithValues: people.enumerated().map { index, person in
            (person.id, Dictionary(uniqueKeysWithValues: questions.map { question in
                (question.id, question.options[index])
            }))
        })
        let result = FlexibleScoringEngine().computeResult(participants: participants, recordedAnswers: answers, questions: questions)
        for domain in CAREDomain.allCases {
            #expect(result.domainScores[domain]?.earnedPoints == 75)
            #expect(result.domainScores[domain]?.maxPossiblePoints == 125)
        }
    }
}
