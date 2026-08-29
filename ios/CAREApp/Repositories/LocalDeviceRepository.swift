import Foundation
import SwiftData

// MARK: - SwiftData Local Device Repository (Contacts + Assessment Protocols)
public final class LocalDeviceRepository: ContactsRepositoryProtocol, AssessmentRepositoryProtocol, @unchecked Sendable {
    private let modelContainer: ModelContainer
    private let maxContacts: Int
    private let maxAssessments: Int
    private let autoPruneAssessments: Bool
    
    public init(
        modelContainer: ModelContainer,
        maxContacts: Int = StorageContainerFactory.maxContactsLimit,
        maxAssessments: Int = StorageContainerFactory.maxAssessmentsLimit,
        autoPruneAssessments: Bool = true
    ) {
        self.modelContainer = modelContainer
        self.maxContacts = maxContacts
        self.maxAssessments = maxAssessments
        self.autoPruneAssessments = autoPruneAssessments
    }
    
    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }
    
    // MARK: - ContactsRepositoryProtocol Implementation
    
    @MainActor
    public func fetchContacts() async throws -> [Person] {
        let descriptor = FetchDescriptor<StoredContact>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let stored = try context.fetch(descriptor)
        return stored.map { $0.toDomain() }
    }
    
    @MainActor
    public func createContact(_ person: Person) async throws -> Person {
        let currentCount = try await fetchContactCount()
        if currentCount >= maxContacts {
            throw StorageLimitError.contactLimitExceeded(max: maxContacts)
        }
        let stored = StoredContact(from: person)
        context.insert(stored)
        try context.save()
        return person
    }
    
    @MainActor
    public func updateContact(_ person: Person) async throws -> Person {
        let targetId = person.id
        let descriptor = FetchDescriptor<StoredContact>(
            predicate: #Predicate { $0.id == targetId }
        )
        if let stored = try context.fetch(descriptor).first {
            stored.name = person.name
            stored.initials = person.initials
            stored.categoryRaw = person.category.rawValue
            stored.age = person.age
            try context.save()
        }
        return person
    }
    
    @MainActor
    public func deleteContact(id: UUID) async throws {
        let descriptor = FetchDescriptor<StoredContact>(
            predicate: #Predicate { $0.id == id }
        )
        if let stored = try context.fetch(descriptor).first {
            context.delete(stored)
            try context.save()
        }
    }
    
    @MainActor
    public func fetchContactCount() async throws -> Int {
        let descriptor = FetchDescriptor<StoredContact>()
        return try context.fetchCount(descriptor)
    }
    
    // MARK: - AssessmentRepositoryProtocol Implementation
    
    public func fetchQuestionBank() async throws -> [SurveyQuestion] {
        return SurveyQuestion.full20QuestionBank
    }
    
    @MainActor
    public func saveAssessmentResult(_ result: AssessmentResult) async throws {
        let currentCount = try await fetchHistoryCount()
        if currentCount >= maxAssessments {
            if autoPruneAssessments {
                // Prune oldest session to keep strictly within max capacity
                let descriptor = FetchDescriptor<StoredAssessmentSession>(
                    sortBy: [SortDescriptor(\.date, order: .forward)]
                )
                if let oldest = try context.fetch(descriptor).first {
                    context.delete(oldest)
                }
            } else {
                throw StorageLimitError.assessmentLimitExceeded(max: maxAssessments)
            }
        }
        
        let storedSession = StoredAssessmentSession(from: result)
        context.insert(storedSession)
        try context.save()
    }
    
    @MainActor
    public func fetchAssessmentHistory() async throws -> [AssessmentResult] {
        let descriptor = FetchDescriptor<StoredAssessmentSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let stored = try context.fetch(descriptor)
        return stored.map { $0.toDomain() }
    }
    
    @MainActor
    public func deleteAssessmentResult(id: UUID) async throws {
        let descriptor = FetchDescriptor<StoredAssessmentSession>(
            predicate: #Predicate { $0.id == id }
        )
        if let stored = try context.fetch(descriptor).first {
            context.delete(stored)
            try context.save()
        }
    }
    
    @MainActor
    public func clearAllHistory() async throws {
        let descriptor = FetchDescriptor<StoredAssessmentSession>()
        let allSessions = try context.fetch(descriptor)
        for session in allSessions {
            context.delete(session)
        }
        try context.save()
    }
    
    @MainActor
    public func fetchHistoryCount() async throws -> Int {
        let descriptor = FetchDescriptor<StoredAssessmentSession>()
        return try context.fetchCount(descriptor)
    }
}
