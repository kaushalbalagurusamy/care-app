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
    
    @Test("TEST-EDP-04: Pseudorandom 3-question sampling and used-pool tracking")
    func testQuizCyclingSamplingAndTracking() async throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let rct = manifest.first(where: { $0.slug == .relationalCulturalTheory })!
        let repo = MockEducationProgressRepository()
        
        // Draw 1: 3 questions from 10
        let session1 = try await repo.fetchNextQuizSession(for: rct, count: 3)
        #expect(session1.questions.count == 3)
        #expect(session1.wasPoolReset == false)
        #expect(session1.remainingInPoolAfterSession == 7)
        
        let record1 = try await repo.fetchProgress(for: .relationalCulturalTheory)
        #expect(record1.usedQuestionIds.count == 3)
        
        // Draw 2: next 3 questions
        let session2 = try await repo.fetchNextQuizSession(for: rct, count: 3)
        #expect(session2.questions.count == 3)
        #expect(session2.wasPoolReset == false)
        #expect(session2.remainingInPoolAfterSession == 4)
        
        let record2 = try await repo.fetchProgress(for: .relationalCulturalTheory)
        #expect(record2.usedQuestionIds.count == 6)
        
        // Check that session 1 and session 2 questions are mutually exclusive
        let ids1 = Set(session1.questions.map(\.id))
        let ids2 = Set(session2.questions.map(\.id))
        #expect(ids1.intersection(ids2).isEmpty, "Questions in consecutive draws must be disjoint until pool reset")
    }
    
    @Test("TEST-EDP-05: Pool exhaustion triggers automatic freshness reset and returns new sample")
    func testPoolExhaustionFreshnessReset() async throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let neuro = manifest.first(where: { $0.slug == .relationalNeuroscience })!
        let repo = MockEducationProgressRepository()
        
        // 3 draws of 3 questions = 9 used, 1 remaining
        _ = try await repo.fetchNextQuizSession(for: neuro, count: 3)
        _ = try await repo.fetchNextQuizSession(for: neuro, count: 3)
        let session3 = try await repo.fetchNextQuizSession(for: neuro, count: 3)
        #expect(session3.remainingInPoolAfterSession == 1)
        
        let record3 = try await repo.fetchProgress(for: .relationalNeuroscience)
        #expect(record3.usedQuestionIds.count == 9)
        
        // Draw 4: requested 3 but only 1 remains -> auto-reset!
        let session4 = try await repo.fetchNextQuizSession(for: neuro, count: 3)
        #expect(session4.wasPoolReset == true, "Pool must trigger freshness reset on exhaustion")
        #expect(session4.questions.count == 3)
        #expect(session4.remainingInPoolAfterSession == 7)
        
        let record4 = try await repo.fetchProgress(for: .relationalNeuroscience)
        #expect(record4.usedQuestionIds.count == 3)
    }
    
    @Test("TEST-EDP-06: Explicit resetQuizPool clears used questions without wiping completion or best score")
    func testManualPoolReset() async throws {
        let repo = MockEducationProgressRepository()
        
        try await repo.markTopicCompleted(slug: .neuroplasticity)
        try await repo.recordQuizSessionResult(
            slug: .neuroplasticity,
            questionIds: ["np-q21", "np-q22", "np-q23"],
            score: 3,
            totalQuestions: 3
        )
        
        let beforeReset = try await repo.fetchProgress(for: .neuroplasticity)
        #expect(beforeReset.isCompleted == true)
        #expect(beforeReset.quizPassed == true)
        #expect(beforeReset.bestScore == 3)
        
        try await repo.resetQuizPool(for: .neuroplasticity)
        
        let afterReset = try await repo.fetchProgress(for: .neuroplasticity)
        #expect(afterReset.usedQuestionIds.isEmpty)
        #expect(afterReset.isCompleted == true)
        #expect(afterReset.quizPassed == true)
        #expect(afterReset.bestScore == 3)
    }
    
    @Test("TEST-EDP-07: recordQuizSessionResult tracks attempts, bestScore, lastScore and marks quizPassed")
    func testRecordQuizSessionResult() async throws {
        let repo = MockEducationProgressRepository()
        
        // Round 1: Failed (1/3)
        try await repo.recordQuizSessionResult(
            slug: .brainHealthyRelationships,
            questionIds: ["bhr-q31", "bhr-q32", "bhr-q33"],
            score: 1,
            totalQuestions: 3
        )
        
        let record1 = try await repo.fetchProgress(for: .brainHealthyRelationships)
        #expect(record1.quizAttemptsCount == 1)
        #expect(record1.lastScore == 1)
        #expect(record1.bestScore == 1)
        #expect(record1.quizPassed == false)
        
        // Round 2: Passed (3/3)
        try await repo.recordQuizSessionResult(
            slug: .brainHealthyRelationships,
            questionIds: ["bhr-q34", "bhr-q35", "bhr-q36"],
            score: 3,
            totalQuestions: 3
        )
        
        let record2 = try await repo.fetchProgress(for: .brainHealthyRelationships)
        #expect(record2.quizAttemptsCount == 2)
        #expect(record2.lastScore == 3)
        #expect(record2.bestScore == 3)
        #expect(record2.quizPassed == true)
        #expect(record2.isCompleted == true)
    }
    
    @Test("TEST-EDP-08: Strict 3/3 mastery gate prevents completion on 2/3 and requires perfect score")
    func testStrictThreeOutOfThreeMasteryGate() async throws {
        let repo = MockEducationProgressRepository()
        
        // Initial state: not completed
        let initial = try await repo.fetchProgress(for: .impactOfRelationships)
        #expect(initial.isCompleted == false)
        
        // Attempt with 2/3 (66%) score
        try await repo.recordQuizSessionResult(
            slug: .impactOfRelationships,
            questionIds: ["ior-q51", "ior-q52", "ior-q53"],
            score: 2,
            totalQuestions: 3
        )
        
        let afterPartial = try await repo.fetchProgress(for: .impactOfRelationships)
        #expect(afterPartial.lastScore == 2)
        #expect(afterPartial.quizPassed == false, "Score of 2/3 must NOT pass under strict 3/3 mastery gate")
        #expect(afterPartial.isCompleted == false, "Score of 2/3 must NOT award topic completion checkmark")
        
        // Retry with 3/3 (100%) score
        try await repo.recordQuizSessionResult(
            slug: .impactOfRelationships,
            questionIds: ["ior-q54", "ior-q55", "ior-q56"],
            score: 3,
            totalQuestions: 3
        )
        
        let afterMastery = try await repo.fetchProgress(for: .impactOfRelationships)
        #expect(afterMastery.lastScore == 3)
        #expect(afterMastery.quizPassed == true, "Score of 3/3 MUST pass mastery gate")
        #expect(afterMastery.isCompleted == true, "Score of 3/3 MUST award topic completion checkmark")
    }
}
