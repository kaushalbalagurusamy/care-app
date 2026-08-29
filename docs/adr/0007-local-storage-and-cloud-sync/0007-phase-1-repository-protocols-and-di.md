# ADR 0007.1: Phase 1 — Repository Protocol Contracts & Dependency Injection

* **Status**: Completed / Verified
* **Date**: 2026-08-28 (Updated 2026-08-29)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 1 decouples all SwiftUI views from concrete data models and mock singletons. It establishes strict protocol interfaces under `ios/CAREApp/Repositories/` and introduces an `@Observable` `AppEnvironment` container.

### Architectural Deliverables & Completion Checklist
- [x] **`ContactsRepositoryProtocol` (`Repositories/ContactsRepositoryProtocol.swift`)**: Thread-safe CRUD protocol interface for fetching, creating, updating, and deleting contacts.
- [x] **`AssessmentRepositoryProtocol` (`Repositories/AssessmentRepositoryProtocol.swift`)**: Thread-safe interface for fetching question banks, saving results, querying history, and clearing data.
- [x] **`MockRepositories` (`Repositories/MockRepositories.swift`)**: Isolated, thread-safe in-memory implementations (`MockContactsRepository`, `MockAssessmentRepository`) for unit testing and SwiftUI Previews.
- [x] **`AppEnvironment` (`Navigation/AppEnvironment.swift`)**: Centralized dependency injection container injected via SwiftUI `.environment(appEnvironment)`.
- [x] **Automated Test Verification (`RepositoryTests.swift`)**: 3 unit test assertions (`TEST-REP-01`, `TEST-REP-02`, `TEST-REP-03`) passing with 100% success rate.

---

## 2. Protocol Interface Contracts

```swift
import Foundation

// MARK: - Contacts Repository Protocol
public protocol ContactsRepositoryProtocol: Sendable {
    func fetchContacts() async throws -> [Person]
    func createContact(_ person: Person) async throws -> Person
    func updateContact(_ person: Person) async throws -> Person
    func deleteContact(id: UUID) async throws
    func fetchContactCount() async throws -> Int
}

// MARK: - Assessment Repository Protocol
public protocol AssessmentRepositoryProtocol: Sendable {
    func fetchQuestionBank() async throws -> [SurveyQuestion]
    func saveAssessmentResult(_ result: AssessmentResult) async throws
    func fetchAssessmentHistory() async throws -> [AssessmentResult]
    func deleteAssessmentResult(id: UUID) async throws
    func clearAllHistory() async throws
    func fetchHistoryCount() async throws -> Int
}
```

---

## 3. SOTA Test Specification Matrix (`RepositoryTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-REP-01`** | Unit | `MockContactsRepository` | Initialize `MockContactsRepository` with 5 default contacts | Call `createContact()`, `fetchContacts()`, and `deleteContact()` | Returns typed `[Person]` models; accurately increments and decrements count. |
| **`TEST-REP-02`** | Unit | `MockAssessmentRepository` | Save completed `AssessmentResult` | Call `fetchAssessmentHistory()` | Successfully returns historical array containing the saved result with identical scores. |
| **`TEST-REP-03`** | Unit / DI | `AppEnvironment` | Initialize `AppEnvironment` with mock mode | Inspect resolved repositories | Properly injects protocol instances; environment propagation causes no memory leaks or retain cycles. |

---

## 4. Acceptance Criteria
- [x] Protocol definitions compile under Swift 6 strict concurrency (`Sendable` compliant).
- [x] `MockContactsRepository` and `MockAssessmentRepository` pass `TEST-REP-01` through `TEST-REP-03`.
- [x] Views can consume `AppEnvironment` without modifying their visual styling.
