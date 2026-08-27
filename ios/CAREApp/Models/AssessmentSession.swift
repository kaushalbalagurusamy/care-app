import Foundation

// MARK: - Transient Assessment Participant (Screen 6 Frequency Calibration)
public struct AssessmentParticipant: Identifiable, Hashable, Codable {
    public let person: Person
    public var percentTimeSpent: Double // 0.0 to 1.0 (e.g. 0.30 = 30%)
    
    public var id: UUID { person.id }
    
    public init(person: Person, percentTimeSpent: Double = 0.20) {
        self.person = person
        self.percentTimeSpent = percentTimeSpent
    }
}

// MARK: - Assessment Session State Machine (Screen 5, 6, 7 Progression)
public struct AssessmentSessionState: Hashable {
    public var participants: [AssessmentParticipant]
    public var totalQuestionsPerPerson: Int
    public var currentParticipantIndex: Int
    public var currentQuestionIndex: Int
    public var recordedAnswers: [UUID: [String: SurveyOption]] // [ParticipantID: [QuestionID: SelectedOption]]
    
    public init(
        participants: [AssessmentParticipant] = [],
        totalQuestionsPerPerson: Int = 20,
        currentParticipantIndex: Int = 0,
        currentQuestionIndex: Int = 0,
        recordedAnswers: [UUID: [String: SurveyOption]] = [:]
    ) {
        self.participants = participants
        self.totalQuestionsPerPerson = totalQuestionsPerPerson
        self.currentParticipantIndex = currentParticipantIndex
        self.currentQuestionIndex = currentQuestionIndex
        self.recordedAnswers = recordedAnswers
    }
    
    public var currentParticipant: AssessmentParticipant? {
        guard currentParticipantIndex < participants.count else { return nil }
        return participants[currentParticipantIndex]
    }
    
    public var isLastQuestionForCurrentPerson: Bool {
        return currentQuestionIndex == totalQuestionsPerPerson - 1
    }
    
    public var isLastParticipant: Bool {
        return currentParticipantIndex == participants.count - 1
    }
    
    public var isComplete: Bool {
        return isLastParticipant && isLastQuestionForCurrentPerson && hasAnswerForCurrentQuestion
    }
    
    public var hasAnswerForCurrentQuestion: Bool {
        guard let pId = currentParticipant?.id else { return false }
        let currentQuestionId = "q_\(currentQuestionIndex + 1)"
        return recordedAnswers[pId]?[currentQuestionId] != nil
    }
    
    public var currentButtonTitle: String {
        if isLastQuestionForCurrentPerson {
            if isLastParticipant {
                return "Complete Assessment"
            } else {
                let nextParticipantName = participants[currentParticipantIndex + 1].person.name
                return "Next: \(nextParticipantName)"
            }
        } else {
            return "Next"
        }
    }
    
    public var progressRatio: Double {
        let totalSteps = Double(participants.count * totalQuestionsPerPerson)
        guard totalSteps > 0 else { return 0.0 }
        let completedSteps = Double((currentParticipantIndex * totalQuestionsPerPerson) + currentQuestionIndex)
        return min(max(completedSteps / totalSteps, 0.0), 1.0)
    }
    
    public mutating func recordAnswer(for questionId: String, option: SurveyOption) {
        guard let pId = currentParticipant?.id else { return }
        if recordedAnswers[pId] == nil {
            recordedAnswers[pId] = [:]
        }
        recordedAnswers[pId]?[questionId] = option
    }
    
    public mutating func advance() -> Bool {
        if isLastQuestionForCurrentPerson {
            if !isLastParticipant {
                currentParticipantIndex += 1
                currentQuestionIndex = 0
                return true
            } else {
                return false // Completed all questions for all participants
            }
        } else {
            currentQuestionIndex += 1
            return true
        }
    }
}
