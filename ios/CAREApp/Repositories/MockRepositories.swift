import Foundation

// MARK: - Thread-Safe In-Memory Mock Contacts Repository
public final class MockContactsRepository: ContactsRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var contacts: [Person]
    
    public init(initialContacts: [Person] = Person.mockRolodex) {
        self.contacts = initialContacts
    }
    
    public func fetchContacts() async throws -> [Person] {
        lock.lock()
        defer { lock.unlock() }
        return contacts
    }
    
    public func createContact(_ person: Person) async throws -> Person {
        lock.lock()
        defer { lock.unlock() }
        contacts.append(person)
        return person
    }
    
    public func updateContact(_ person: Person) async throws -> Person {
        lock.lock()
        defer { lock.unlock() }
        if let idx = contacts.firstIndex(where: { $0.id == person.id }) {
            contacts[idx] = person
        }
        return person
    }
    
    public func deleteContact(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        contacts.removeAll { $0.id == id }
    }
    
    public func fetchContactCount() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        return contacts.count
    }
}

// MARK: - Thread-Safe In-Memory Mock Assessment Repository
public final class MockAssessmentRepository: AssessmentRepositoryProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var history: [AssessmentResult]
    private let questionBank: [SurveyQuestion]
    
    public init(
        initialHistory: [AssessmentResult] = [AssessmentResult.figmaMockResult],
        questionBank: [SurveyQuestion] = SurveyQuestion.full20QuestionBank
    ) {
        self.history = initialHistory
        self.questionBank = questionBank
    }
    
    public func fetchQuestionBank() async throws -> [SurveyQuestion] {
        return questionBank
    }
    
    public func saveAssessmentResult(_ result: AssessmentResult) async throws {
        lock.lock()
        defer { lock.unlock() }
        history.insert(result, at: 0)
    }
    
    public func fetchAssessmentHistory() async throws -> [AssessmentResult] {
        lock.lock()
        defer { lock.unlock() }
        return history
    }
    
    public func deleteAssessmentResult(id: UUID) async throws {
        lock.lock()
        defer { lock.unlock() }
        history.removeAll { $0.id == id }
    }
    
    public func clearAllHistory() async throws {
        lock.lock()
        defer { lock.unlock() }
        history.removeAll()
    }
    
    public func fetchHistoryCount() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        return history.count
    }
}
