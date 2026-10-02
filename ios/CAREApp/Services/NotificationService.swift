import Foundation
import UserNotifications

// MARK: - Notification Manager Protocol (Swift 6 & Sendable)
public protocol NotificationSchedulerProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleBiWeeklyReminder(preferredHour: Int, preferredWeekday: Int) async throws
    func scheduleAssessmentReminder(frequency: String) async throws
    func cancelReminders() async throws
    func isReminderScheduled() async throws -> Bool
}

// MARK: - Production Local Notification Service (UNUserNotificationCenter)
public final class NotificationService: NotificationSchedulerProtocol, @unchecked Sendable {
    public static let reminderIdentifier = "com.careapp.biweekly.assessment.reminder"
    private let center = UNUserNotificationCenter.current()
    
    public init() {}
    
    public func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }
    
    public func scheduleBiWeeklyReminder(preferredHour: Int = 19, preferredWeekday: Int = 1) async throws {
        try await scheduleAssessmentReminder(frequency: "biweekly")
    }

    public func scheduleAssessmentReminder(frequency: String) async throws {
        // Cancel existing pending reminders first to prevent duplicates
        await cancelReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "C.A.R.E. Check-In"
        content.body = "🌱 Time for your Relational Safety check-in. Tap to reflect on your connections."
        content.sound = .default

        let days: Double
        switch frequency {
        case "2x/week": days = 3.5
        case "1x/week": days = 7
        case "monthly": days = 30
        case "every 3 months": days = 90
        default: days = 14
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: days * 24 * 60 * 60, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationService.reminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    public func cancelReminders() async {
        center.removePendingNotificationRequests(withIdentifiers: [NotificationService.reminderIdentifier])
    }
    
    public func isReminderScheduled() async -> Bool {
        let requests = await center.pendingNotificationRequests()
        return requests.contains(where: { $0.identifier == NotificationService.reminderIdentifier })
    }
}

// MARK: - In-Memory Mock Notification Service for Unit Testing & Previews
public final class MockNotificationService: NotificationSchedulerProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var isScheduled: Bool
    public var shouldGrantAuthorization: Bool
    
    public init(isScheduled: Bool = false, shouldGrantAuthorization: Bool = true) {
        self.isScheduled = isScheduled
        self.shouldGrantAuthorization = shouldGrantAuthorization
    }
    
    public func requestAuthorization() async throws -> Bool {
        return shouldGrantAuthorization
    }
    
    public func scheduleBiWeeklyReminder(preferredHour: Int = 19, preferredWeekday: Int = 1) async throws {
        lock.lock()
        defer { lock.unlock() }
        isScheduled = true
    }

    public func scheduleAssessmentReminder(frequency: String) async throws {
        try await scheduleBiWeeklyReminder(preferredHour: 19, preferredWeekday: 1)
    }
    
    public func cancelReminders() async throws {
        lock.lock()
        defer { lock.unlock() }
        isScheduled = false
    }
    
    public func isReminderScheduled() async throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return isScheduled
    }
}
