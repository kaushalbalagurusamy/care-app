import Testing
import Foundation
@testable import CAREApp

// MARK: - Phase 4: Education Progress Tests (TEST-EDP-01 through TEST-EDP-03)
@Suite("Phase 4: Education Progress Tracking Test Suite")
struct EducationProgressTests {
    
    @Test("TEST-EDP-01: Mark topic as completed updates repository and count")
    func testMarkTopicCompleted() async throws {
        let repo = MockEducationProgressRepository()
        
        let initialCount = try await repo.completedTopicsCount()
        #expect(initialCount == 0)
        
        let initialProgress = try await repo.fetchProgress(for: .relationalCulturalTheory)
        #expect(initialProgress.isCompleted == false)
        #expect(initialProgress.completedAt == nil)
        
        try await repo.markTopicCompleted(slug: .relationalCulturalTheory)
        
        let updatedProgress = try await repo.fetchProgress(for: .relationalCulturalTheory)
        #expect(updatedProgress.isCompleted == true)
        #expect(updatedProgress.completedAt != nil)
        
        let updatedCount = try await repo.completedTopicsCount()
        #expect(updatedCount == 1)
        
        // Also test LocalEducationProgressRepository with isolated suite
        let suiteName = "test.education.progress.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let localRepo = LocalEducationProgressRepository(userDefaults: defaults, storageKey: "progress_test")
        
        try await localRepo.markTopicCompleted(slug: .neuroplasticity)
        let localRecord = try await localRepo.fetchProgress(for: .neuroplasticity)
        #expect(localRecord.isCompleted == true)
        #expect(try await localRepo.completedTopicsCount() == 1)
        defaults.removePersistentDomain(forName: suiteName)
    }
    
    @Test("TEST-EDP-02: Right-to-Erasure full purge resets all progress")
    func testResetProgressPurge() async throws {
        let repo = MockEducationProgressRepository()
        
        try await repo.markTopicCompleted(slug: .relationalCulturalTheory)
        try await repo.markTopicCompleted(slug: .relationalNeuroscience)
        try await repo.markTopicCompleted(slug: .neuroplasticity)
        #expect(try await repo.completedTopicsCount() == 3)
        
        try await repo.resetProgress()
        #expect(try await repo.completedTopicsCount() == 0)
        
        let rct = try await repo.fetchProgress(for: .relationalCulturalTheory)
        #expect(rct.isCompleted == false)
        
        // Test LocalEducationProgressRepository purge
        let suiteName = "test.education.purge.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let localRepo = LocalEducationProgressRepository(userDefaults: defaults, storageKey: "progress_purge_test")
        
        try await localRepo.markTopicCompleted(slug: .powerOverVsPowerWith)
        #expect(try await localRepo.completedTopicsCount() == 1)
        
        try await localRepo.resetProgress()
        #expect(try await localRepo.completedTopicsCount() == 0)
        defaults.removePersistentDomain(forName: suiteName)
    }
    
    @Test("TEST-EDP-03: Record quiz success updates quizPassed and completed state")
    func testRecordQuizResult() async throws {
        let repo = MockEducationProgressRepository()
        
        let beforeQuiz = try await repo.fetchProgress(for: .relationalNeuroscience)
        #expect(beforeQuiz.quizPassed == false)
        #expect(beforeQuiz.quizPassedAt == nil)
        
        try await repo.recordQuizResult(slug: .relationalNeuroscience, passed: true)
        
        let afterQuiz = try await repo.fetchProgress(for: .relationalNeuroscience)
        #expect(afterQuiz.quizPassed == true)
        #expect(afterQuiz.quizPassedAt != nil)
        #expect(afterQuiz.isCompleted == true)
        
        // Test failed quiz doesn't mark passed
        try await repo.recordQuizResult(slug: .brainHealthyRelationships, passed: false)
        let failedRecord = try await repo.fetchProgress(for: .brainHealthyRelationships)
        #expect(failedRecord.quizPassed == false)
        #expect(failedRecord.quizPassedAt == nil)
    }
}
