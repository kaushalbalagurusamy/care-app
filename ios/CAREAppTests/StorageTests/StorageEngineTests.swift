import Testing
import Foundation
import SwiftData
@testable import CAREApp

@Suite("Phase 6.2: SwiftData CloudKit Storage Engine & Capacity Limits Test Suite")
struct StorageEngineTests {
    
    @Test("TEST-STO-01: StoredContact executes complete CRUD lifecycle in SwiftData")
    @MainActor
    func testStoredContactCRUD() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let context = container.mainContext
        
        // 1. Create
        let contact = StoredContact(name: "Sarah Mitchell", initials: "SM", categoryRaw: "partner", age: 32)
        context.insert(contact)
        try context.save()
        
        // 2. Read
        let descriptor = FetchDescriptor<StoredContact>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results.first?.name == "Sarah Mitchell")
        #expect(results.first?.toDomain().initials == "SM")
        
        // 3. Update
        results.first?.name = "Sarah M. Cooper"
        try context.save()
        let updated = try context.fetch(descriptor).first
        #expect(updated?.name == "Sarah M. Cooper")
        
        // 4. Delete
        if let target = updated {
            context.delete(target)
            try context.save()
        }
        #expect(try context.fetch(descriptor).isEmpty)
    }

    @Test("TEST-STO-02: Deleting StoredAssessmentSession cascade-deletes all participant records")
    @MainActor
    func testCascadeDeletion() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let context = container.mainContext
        
        let p1 = StoredParticipantResult(personName: "Sarah", initials: "SM")
        let p2 = StoredParticipantResult(personName: "James", initials: "JC")
        let session = StoredAssessmentSession(
            totalScore: 85.0,
            participants: [p1, p2]
        )
        context.insert(session)
        try context.save()
        
        #expect(try context.fetchCount(FetchDescriptor<StoredAssessmentSession>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<StoredParticipantResult>()) == 2)
        
        // Delete parent session
        context.delete(session)
        try context.save()
        
        #expect(try context.fetchCount(FetchDescriptor<StoredAssessmentSession>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<StoredParticipantResult>()) == 0)
    }

    @Test("TEST-STO-03: SwiftData persistent models satisfy CloudKit default value invariants")
    func testCloudKitModelInvariants() {
        let emptyContact = StoredContact()
        #expect(emptyContact.name.isEmpty)
        #expect(emptyContact.initials.isEmpty)
        #expect(emptyContact.categoryRaw == "partner")
        
        let emptySession = StoredAssessmentSession()
        #expect(emptySession.totalScore == 0.0)
        #expect(emptySession.overallTierRaw == "healthy")
        #expect(emptySession.participants != nil)
        
        let emptyParticipant = StoredParticipantResult()
        #expect(emptyParticipant.personName.isEmpty)
        #expect(emptyParticipant.individualScore == 0.0)
    }

    @Test("TEST-STO-04: LocalDeviceRepository enforces strict 50-contact capacity ceiling guard")
    @MainActor
    func testContactLimitGuard() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(modelContainer: container, maxContacts: 50)
        
        // Pre-populate with 50 contacts
        for i in 1...50 {
            let p = Person(name: "Contact \(i)", initials: "C\(i)", category: .friend, age: 25)
            _ = try await repo.createContact(p)
        }
        #expect(try await repo.fetchContactCount() == 50)
        
        // Attempting to insert 51st contact must throw StorageLimitError
        let overflowPerson = Person(name: "Overflow Person", initials: "OP", category: .coworker, age: 30)
        
        var threwExpectedError = false
        do {
            _ = try await repo.createContact(overflowPerson)
        } catch let error as StorageLimitError {
            if case .contactLimitExceeded(let max) = error {
                #expect(max == 50)
                threwExpectedError = true
            }
        }
        #expect(threwExpectedError == true)
        #expect(try await repo.fetchContactCount() == 50)
    }

    @Test("TEST-STO-05: LocalDeviceRepository auto-prunes oldest assessment when reaching 50-session ceiling")
    @MainActor
    func testAssessmentLimitAndPruning() async throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let repo = LocalDeviceRepository(
            modelContainer: container,
            maxAssessments: 3,
            autoPruneAssessments: true
        )
        
        let oldestDate = Date().addingTimeInterval(-10000)
        let middleDate = Date().addingTimeInterval(-5000)
        let recentDate = Date()
        
        let res1 = AssessmentResult(
            domainScores: [:],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.8, moderatePercentage: 0.1, highRiskPercentage: 0.1),
            individualResults: [],
            timestamp: oldestDate
        )
        let res2 = AssessmentResult(
            domainScores: [:],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.7, moderatePercentage: 0.2, highRiskPercentage: 0.1),
            individualResults: [],
            timestamp: middleDate
        )
        let res3 = AssessmentResult(
            domainScores: [:],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.6, moderatePercentage: 0.2, highRiskPercentage: 0.2),
            individualResults: [],
            timestamp: recentDate
        )
        
        try await repo.saveAssessmentResult(res1)
        try await repo.saveAssessmentResult(res2)
        try await repo.saveAssessmentResult(res3)
        #expect(try await repo.fetchHistoryCount() == 3)
        
        // 4th session insertion auto-prunes res1 (the oldest session)
        let res4 = AssessmentResult(
            domainScores: [:],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.9, moderatePercentage: 0.1, highRiskPercentage: 0.0),
            individualResults: [],
            timestamp: Date().addingTimeInterval(100)
        )
        try await repo.saveAssessmentResult(res4)
        
        #expect(try await repo.fetchHistoryCount() == 3)
        let history = try await repo.fetchAssessmentHistory()
        #expect(!history.contains(where: { $0.id == res1.id }))
        #expect(history.contains(where: { $0.id == res4.id }))
    }

    @Test("TEST-STO-06: Maximum capacity storage footprint benchmark strictly conforms to < 500 KB ceiling")
    @MainActor
    func testStorageFootprintBenchmark() throws {
        let container = StorageContainerFactory.createInMemoryContainer()
        let context = container.mainContext
        
        // Populate max 50 contacts
        for i in 1...50 {
            let contact = StoredContact(name: "Person Number \(i)", initials: "P\(i)", categoryRaw: "friend", age: 25 + (i % 20))
            context.insert(contact)
        }
        
        // Populate max 50 full assessment sessions (each with 5 participants)
        for s in 1...50 {
            let participants = (1...5).map { p in
                StoredParticipantResult(
                    personName: "Participant \(p) of Session \(s)",
                    initials: "P\(p)",
                    percentTimeSpent: 0.20,
                    individualScore: 82.5,
                    safetyTierRaw: "Safe",
                    calmScore: 21.0,
                    acceptedScore: 22.0,
                    resonantScore: 19.5,
                    energeticScore: 20.0
                )
            }
            let session = StoredAssessmentSession(
                date: Date().addingTimeInterval(Double(-s * 86400)),
                totalScore: 82.5,
                overallTierRaw: "healthy",
                safePercentage: 0.35,
                moderatePercentage: 0.40,
                highRiskPercentage: 0.25,
                calmScore: 21.0,
                acceptedScore: 22.0,
                resonantScore: 19.5,
                energeticScore: 20.0,
                participants: participants
            )
            context.insert(session)
        }
        try context.save()
        
        let allContacts = try context.fetch(FetchDescriptor<StoredContact>())
        let allSessions = try context.fetch(FetchDescriptor<StoredAssessmentSession>())
        let allParticipants = try context.fetch(FetchDescriptor<StoredParticipantResult>())
        
        #expect(allContacts.count == 50)
        #expect(allSessions.count == 50)
        #expect(allParticipants.count == 250)
        
        // Approximate serialized in-memory JSON footprint calculation
        let encoder = JSONEncoder()
        let domainContacts = allContacts.map { $0.toDomain() }
        let domainSessions = allSessions.map { $0.toDomain() }
        
        let contactsData = try encoder.encode(domainContacts)
        let sessionsData = try encoder.encode(domainSessions)
        let totalPayloadBytes = contactsData.count + sessionsData.count
        
        let totalKilobytes = Double(totalPayloadBytes) / 1024.0
        print("Measured total 50-contact + 50-session footprint: \(totalKilobytes) KB")
        
        // Invariant: Total serialized payload must be strictly under 500 KB (actual is ~150-200 KB)
        #expect(totalKilobytes < 500.0, "Storage footprint \(totalKilobytes) KB exceeded 500 KB invariant")
    }
}
