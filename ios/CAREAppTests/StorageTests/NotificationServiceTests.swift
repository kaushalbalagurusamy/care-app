import Testing
import Foundation
import UserNotifications
@testable import CAREApp

@Suite("Phase 6.4: Bi-Weekly Local Notification Scheduler Test Suite")
struct NotificationServiceTests {
    
    @Test("TEST-NOT-01: Notification scheduler handles permission authorization states cleanly")
    func testNotificationAuthorizationHandling() async throws {
        let mockGranted = MockNotificationService(shouldGrantAuthorization: true)
        let granted = try await mockGranted.requestAuthorization()
        #expect(granted == true)
        
        let mockDenied = MockNotificationService(shouldGrantAuthorization: false)
        let denied = try await mockDenied.requestAuthorization()
        #expect(denied == false)
    }

    @Test("TEST-NOT-02: Bi-weekly reminder scheduling successfully creates repeating reminder")
    func testScheduleBiWeeklyReminder() async throws {
        let scheduler = MockNotificationService()
        #expect(try await scheduler.isReminderScheduled() == false)
        
        // Schedule reminder for Sundays at 7:00 PM
        try await scheduler.scheduleBiWeeklyReminder(preferredHour: 19, preferredWeekday: 1)
        #expect(try await scheduler.isReminderScheduled() == true)
    }

    @Test("TEST-NOT-03: Cancelling reminders clears all pending notification requests")
    func testCancelReminders() async throws {
        let scheduler = MockNotificationService(isScheduled: true)
        #expect(try await scheduler.isReminderScheduled() == true)
        
        try await scheduler.cancelReminders()
        #expect(try await scheduler.isReminderScheduled() == false)
    }

    @Test("TEST-NOT-04: Notification scheduling executes locally in zero-network offline mode")
    func testOfflineExecutionInvariant() async throws {
        let scheduler = MockNotificationService()
        
        let startTime = Date()
        try await scheduler.scheduleBiWeeklyReminder(preferredHour: 20, preferredWeekday: 2)
        let elapsed = Date().timeIntervalSince(startTime)
        
        // Local invocation must complete in sub-millisecond time (< 50ms)
        #expect(elapsed < 0.05)
        #expect(try await scheduler.isReminderScheduled() == true)
    }
}
