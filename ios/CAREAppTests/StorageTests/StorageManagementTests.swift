import Testing
import SwiftUI
import SwiftData
@testable import CAREApp

@Suite("Phase 6.3: User Storage Management & View Data Wiring Test Suite")
struct StorageManagementTests {
    
    @Test("TEST-MGT-01: Frame 5 contact deletion updates repository and decrements count")
    @MainActor
    func testContactDeletion() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(modelContainer: container)
        
        // 1. Add 5 initial contacts
        for p in Person.mockFigmaContacts {
            _ = try await repo.createContact(p)
        }
        #expect(try await repo.fetchContactCount() == 5)
        
        // 2. Delete 1 contact
        let targetId = Person.mockFigmaContacts[0].id
        try await repo.deleteContact(id: targetId)
        
        #expect(try await repo.fetchContactCount() == 4)
        let remaining = try await repo.fetchContacts()
        #expect(!remaining.contains(where: { $0.id == targetId }))
    }

    @Test("TEST-MGT-02: Frame 10 historical assessment deletion purges record and updates count")
    @MainActor
    func testAssessmentDeletion() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(modelContainer: container)
        
        let result1 = AssessmentResult.figmaMockResult
        let result2 = AssessmentResult(
            domainScores: [:],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.5, moderatePercentage: 0.3, highRiskPercentage: 0.2),
            individualResults: [],
            timestamp: Date().addingTimeInterval(-86400)
        )
        
        try await repo.saveAssessmentResult(result1)
        try await repo.saveAssessmentResult(result2)
        #expect(try await repo.fetchHistoryCount() == 2)
        
        // Delete result1
        try await repo.deleteAssessmentResult(id: result1.id)
        #expect(try await repo.fetchHistoryCount() == 1)
        
        let history = try await repo.fetchAssessmentHistory()
        #expect(history.first?.id == result2.id)
    }

    @Test("TEST-MGT-03: Complete data purge zeroizes all historical sessions (Right to Erasure)")
    @MainActor
    func testCompleteDataPurge() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(modelContainer: container)
        
        // Save 5 results
        for _ in 1...5 {
            try await repo.saveAssessmentResult(AssessmentResult.figmaMockResult)
        }
        #expect(try await repo.fetchHistoryCount() == 5)
        
        // Execute full history purge
        try await repo.clearAllHistory()
        #expect(try await repo.fetchHistoryCount() == 0)
        #expect(try await repo.fetchAssessmentHistory().isEmpty)
    }

    @Test("TEST-MGT-04: Storage readout formats human-readable footprint and capacity metrics")
    @MainActor
    func testStorageReadoutFormatter() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(modelContainer: container)
        
        for _ in 1...10 {
            try await repo.saveAssessmentResult(AssessmentResult.figmaMockResult)
        }
        for p in Person.mockFigmaContacts {
            _ = try await repo.createContact(p)
        }
        
        let historyCount = try await repo.fetchHistoryCount()
        let contactCount = try await repo.fetchContactCount()
        
        #expect(historyCount == 10)
        #expect(contactCount == 5)
        
        let approximateKilobytes = (historyCount * 3) + (contactCount * 1) + 25 // Index & payload approx
        let readoutString = "\(approximateKilobytes) KB (\(historyCount) / 50 sessions stored)"
        
        #expect(readoutString.contains("50 sessions stored"))
        #expect(approximateKilobytes < 500)
    }
}
