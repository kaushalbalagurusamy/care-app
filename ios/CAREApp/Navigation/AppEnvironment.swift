import SwiftUI

// MARK: - Swift 6 Observable Application Dependency Injection Container
@Observable
@MainActor
public final class AppEnvironment {
    public let contactsRepo: any ContactsRepositoryProtocol
    public let assessmentRepo: any AssessmentRepositoryProtocol
    public let notificationScheduler: any NotificationSchedulerProtocol
    
    public init(
        contactsRepo: any ContactsRepositoryProtocol = MockContactsRepository(),
        assessmentRepo: any AssessmentRepositoryProtocol = MockAssessmentRepository(),
        notificationScheduler: any NotificationSchedulerProtocol = MockNotificationService()
    ) {
        self.contactsRepo = contactsRepo
        self.assessmentRepo = assessmentRepo
        self.notificationScheduler = notificationScheduler
    }
    
    /// Pre-configured environment for SwiftUI previews & unit testing
    public static var preview: AppEnvironment {
        AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository(),
            notificationScheduler: MockNotificationService()
        )
    }
}
