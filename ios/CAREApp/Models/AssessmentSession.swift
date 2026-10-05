import Foundation

public enum AssessmentDailyPolicy {
    public static func canStart(after latestCompletion: Date?, now: Date = .now, calendar: Calendar = .current) -> Bool {
        guard let latestCompletion else { return true }
        return !calendar.isDate(latestCompletion, inSameDayAs: now)
    }
}

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
public struct AssessmentSessionState: Hashable, Codable, Sendable {
    public static let requiredParticipantCount = 5
    public static func canStart(with participantCount: Int) -> Bool {
        participantCount == requiredParticipantCount
    }
    public static func canStart(with participants: [AssessmentParticipant]) -> Bool {
        canStart(with: participants.count) && Set(participants.map(\.id)).count == requiredParticipantCount
    }
    public var participants: [AssessmentParticipant]
    public var id: UUID? = UUID()
    public var totalQuestionsPerPerson: Int
    public var currentParticipantIndex: Int
    public var currentQuestionIndex: Int
    public var recordedAnswers: [UUID: [String: SurveyOption]] // [ParticipantID: [QuestionID: SelectedOption]]

    
    public init(
        participants: [AssessmentParticipant] = [],
        id: UUID? = UUID(),
        totalQuestionsPerPerson: Int = 20,
        currentParticipantIndex: Int = 0,
        currentQuestionIndex: Int = 0,
        recordedAnswers: [UUID: [String: SurveyOption]] = [:]
    ) {
        self.participants = participants
        self.id = id
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

    public var isFinalQuestion: Bool {
        return isLastParticipant && isLastQuestionForCurrentPerson
    }
    
    public var isComplete: Bool {
        return isFinalQuestion && hasAnswerForCurrentQuestion
    }

    public var isFullyAnswered: Bool {
        guard Self.canStart(with: participants), totalQuestionsPerPerson == 20 else { return false }
        let questions = SurveyQuestion.full20QuestionBank
        let questionIDs = Set(questions.map(\.id))
        guard questions.count == 20, questionIDs.count == 20,
              Set(recordedAnswers.keys) == Set(participants.map(\.id)) else { return false }
        let byID = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
        return participants.allSatisfy { participant in
            guard let answers = recordedAnswers[participant.id], Set(answers.keys) == questionIDs else { return false }
            return answers.allSatisfy { questionID, selected in
                byID[questionID]?.options.contains(where: {
                    $0.id == selected.id && $0.rawScoreValue == selected.rawScoreValue
                }) == true
            }
        }
    }
    
    public var hasStarted: Bool {
        return currentParticipantIndex > 0 || currentQuestionIndex > 0 || recordedAnswers.values.contains { !$0.isEmpty }
    }
    
    public var currentQuestionId: String {
        return "q_\(currentQuestionIndex + 1)"
    }
    
    public var hasAnswerForCurrentQuestion: Bool {
        guard let pId = currentParticipant?.id else { return false }
        return recordedAnswers[pId]?[currentQuestionId] != nil
    }

    public var currentAnswer: SurveyOption? {
        guard let pId = currentParticipant?.id else { return nil }
        return recordedAnswers[pId]?[currentQuestionId]
    }

    @discardableResult
    public mutating func moveToPreviousQuestion() -> Bool {
        guard currentParticipantIndex >= 0, currentParticipantIndex < participants.count,
              currentQuestionIndex >= 0, currentQuestionIndex < totalQuestionsPerPerson else { return false }
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            return true
        }
        guard currentParticipantIndex > 0 else { return false }
        currentParticipantIndex -= 1
        currentQuestionIndex = totalQuestionsPerPerson - 1
        return true
    }
    
    public var canAdvance: Bool {
        return hasAnswerForCurrentQuestion
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
        // Enforce strict validation: cannot advance without recording an answer for the current question
        guard hasAnswerForCurrentQuestion else {
            return false
        }
        
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
    
    // MARK: - Draft Persistence Helpers
    public static let draftStorageKey = "care_active_assessment_draft_session"
    
    public static func loadDraft() -> AssessmentSessionState? {
        guard let data = UserDefaults.standard.data(forKey: draftStorageKey),
              let session = try? JSONDecoder().decode(AssessmentSessionState.self, from: data) else {
            return nil
        }
        return session.hasStarted && canStart(with: session.participants) ? session : nil
    }
    
    public func saveDraft() {
        guard hasStarted else {
            Self.clearDraft()
            return
        }
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.draftStorageKey)
        }
    }
    
    public static func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftStorageKey)
    }
}
