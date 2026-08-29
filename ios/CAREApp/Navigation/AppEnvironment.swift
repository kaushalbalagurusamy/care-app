import SwiftUI

// MARK: - Swift 6 Observable Application Dependency Injection Container
@Observable
@MainActor
public final class AppEnvironment {
    public let contactsRepo: any ContactsRepositoryProtocol
    public let assessmentRepo: any AssessmentRepositoryProtocol
    public let notificationScheduler: any NotificationSchedulerProtocol
    public let biometricService: any BiometricAuthServiceProtocol
    public let appLockManager: AppLockManager
    
    public init(
        contactsRepo: any ContactsRepositoryProtocol = MockContactsRepository(),
        assessmentRepo: any AssessmentRepositoryProtocol = MockAssessmentRepository(),
        notificationScheduler: any NotificationSchedulerProtocol = MockNotificationService(),
        biometricService: any BiometricAuthServiceProtocol = BiometricAuthService(),
        appLockManager: AppLockManager? = nil
    ) {
        self.contactsRepo = contactsRepo
        self.assessmentRepo = assessmentRepo
        self.notificationScheduler = notificationScheduler
        self.biometricService = biometricService
        self.appLockManager = appLockManager ?? AppLockManager(biometricService: biometricService)
    }
    
    /// Pre-configured environment for SwiftUI previews & unit testing
    public static var preview: AppEnvironment {
        let mockBio = MockBiometricAuthService(shouldSucceed: true)
        return AppEnvironment(
            contactsRepo: MockContactsRepository(),
            assessmentRepo: MockAssessmentRepository(),
            notificationScheduler: MockNotificationService(),
            biometricService: mockBio,
            appLockManager: AppLockManager(biometricService: mockBio, initiallyLocked: false)
        )
    }
}
