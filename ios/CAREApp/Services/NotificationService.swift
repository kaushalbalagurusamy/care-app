import Foundation
import UserNotifications

// MARK: - Notification Manager Protocol (Swift 6 & Sendable)
public protocol NotificationSchedulerProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleBiWeeklyReminder(preferredHour: Int, preferredWeekday: Int) async throws
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
        // Cancel existing pending reminders first to prevent duplicates
        await cancelReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "C.A.R.E. Check-In"
        content.body = "🌱 Time for your bi-weekly Relational Safety check-in. Tap to reflect on your connections."
        content.sound = .default
        
        // Configure bi-weekly calendar trigger (e.g. Sunday at 7:00 PM)
        var dateComponents = DateComponents()
        dateComponents.weekday = preferredWeekday // 1 = Sunday
        dateComponents.hour = preferredHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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
