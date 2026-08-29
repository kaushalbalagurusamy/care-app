import SwiftUI

// MARK: - Swift 6 Observable Application Dependency Injection Container
@Observable
@MainActor
public final class AppEnvironment {
    public let contactsRepo: any ContactsRepositoryProtocol
    public let assessmentRepo: any AssessmentRepositoryProtocol
    
    public init(
        contactsRepo: any ContactsRepositoryProtocol = MockContactsRepository(),
        assessmentRepo: any AssessmentRepositoryProtocol = MockAssessmentRepository()
    ) {
        self.contactsRepo = contactsRepo
        self.assessmentRepo = assessmentRepo
    }
    
    /// Pre-configured environment for SwiftUI previews & unit testing
    public static var preview: AppEnvironment {
        AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository()
        )
    }
}
