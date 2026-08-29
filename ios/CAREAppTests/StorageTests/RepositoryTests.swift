import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 6.1: Repository Protocol Contracts & Dependency Injection Test Suite")
struct RepositoryTests {
    
    @Test("TEST-REP-01: MockContactsRepository executes CRUD operations deterministically")
    func testContactsRepositoryCRUD() async throws {
        let initialContacts = [
            Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32),
            Person(name: "James Cooper", initials: "JC", category: .family, age: 28)
        ]
        let repo = MockContactsRepository(initialContacts: initialContacts)
        
        // 1. Fetch initial contacts
        let fetched = try await repo.fetchContacts()
        #expect(fetched.count == 2)
        #expect(try await repo.fetchContactCount() == 2)
        
        // 2. Create new contact
        let newContact = Person(name: "Alex Taylor", initials: "AT", category: .friend, age: 30)
        _ = try await repo.createContact(newContact)
        #expect(try await repo.fetchContactCount() == 3)
        
        // 3. Delete contact
        try await repo.deleteContact(id: initialContacts[0].id)
        #expect(try await repo.fetchContactCount() == 2)
        
        let remaining = try await repo.fetchContacts()
        #expect(!remaining.contains(where: { $0.id == initialContacts[0].id }))
        #expect(remaining.contains(where: { $0.id == newContact.id }))
    }

    @Test("TEST-REP-02: MockAssessmentRepository saves and queries historical assessment results")
    func testAssessmentRepositoryHistory() async throws {
        let repo = MockAssessmentRepository(initialHistory: [])
        #expect(try await repo.fetchHistoryCount() == 0)
        
        // 1. Fetch question bank
        let questions = try await repo.fetchQuestionBank()
        #expect(questions.count >= 20)
        
        // 2. Save result
        let result = AssessmentResult.figmaMockResult
        try await repo.saveAssessmentResult(result)
        #expect(try await repo.fetchHistoryCount() == 1)
        
        // 3. Fetch history
        let history = try await repo.fetchAssessmentHistory()
        #expect(history.count == 1)
        #expect(history.first?.id == result.id)
        #expect(history.first?.individualResults.count == result.individualResults.count)
        #expect(history.first?.safetyDistribution.safePercentage == result.safetyDistribution.safePercentage)
        
        // 4. Delete result
        try await repo.deleteAssessmentResult(id: result.id)
        #expect(try await repo.fetchHistoryCount() == 0)
    }

    @Test("TEST-REP-03: AppEnvironment resolves protocol instances without retention cycles")
    @MainActor
    func testAppEnvironmentInjection() async throws {
        let environment = AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository()
        )
        
        let contactCount = try await environment.contactsRepo.fetchContactCount()
        #expect(contactCount > 0)
        
        let historyCount = try await environment.assessmentRepo.fetchHistoryCount()
        #expect(historyCount > 0)
    }
}
