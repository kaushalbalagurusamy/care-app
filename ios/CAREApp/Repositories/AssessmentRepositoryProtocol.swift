import Foundation

// MARK: - Assessment Repository Protocol (Sendable & Swift 6 Compliant)
public protocol AssessmentRepositoryProtocol: Sendable {
    func fetchQuestionBank() async throws -> [SurveyQuestion]
    func saveAssessmentResult(_ result: AssessmentResult) async throws
    func fetchAssessmentHistory() async throws -> [AssessmentResult]
    func deleteAssessmentResult(id: UUID) async throws
    func clearAllHistory() async throws
    func fetchHistoryCount() async throws -> Int
}
