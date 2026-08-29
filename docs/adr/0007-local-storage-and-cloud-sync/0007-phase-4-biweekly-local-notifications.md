# ADR 0007.4: Phase 4 — Bi-Weekly Local Notification Scheduler

* **Status**: Completed / Verified
* **Date**: 2026-08-28 (Updated 2026-08-29)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 4 implements privacy-preserving, zero-backend assessment reminders. It builds a local notification manager using iOS native `UserNotifications.framework` configured for bi-weekly repeating reminders.

### Architectural Deliverables & Completion Checklist
- [x] **`NotificationService` & `NotificationSchedulerProtocol` (`Services/NotificationService.swift`)**:
  - Encapsulates `UNUserNotificationCenter` permission requests, scheduling, cancellation, and status checks.
  - Conforms to Swift 6 `Sendable` standards.
- [x] **Bi-Weekly Repeating Trigger**:
  - Uses `UNCalendarNotificationTrigger` repeating every 14 days on the user's preferred weekday/hour (e.g. Every 2nd Sunday at 7:00 PM).
  - Localized reminder copy: *"🌱 Time for your bi-weekly Relational Safety check-in. Tap to reflect on your connections."*
- [x] **In-App Notification Settings Toggle (`Views/StorageSettingsView.swift`)**:
  - Placed in the storage/settings sheet with real-time toggle handling permission checks and instant schedule updates.
- [x] **Automated Test Verification (`NotificationServiceTests.swift`)**:
  - 4 unit assertions (`TEST-NOT-01` through `TEST-NOT-04`) passing with 100% success rate.

---

## 2. Notification Service Contract

```swift
import UserNotifications

public protocol NotificationSchedulerProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleBiWeeklyReminder(preferredHour: Int, preferredWeekday: Int) async throws
    func cancelReminders() async throws
    func isReminderScheduled() async throws -> Bool
}
```

---

## 3. SOTA Test Specification Matrix (`NotificationServiceTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-NOT-01`** | Unit | Permission Handling | Mock `UNUserNotificationCenter` | Invoke `requestAuthorization()` with granted=true/false | Returns accurate authorization status without throwing or crashing. |
| **`TEST-NOT-02`** | Unit | Bi-Weekly Schedule Trigger | Notification permissions authorized | Call `scheduleBiWeeklyReminder(hour: 19, weekday: 1)` | Creates a `UNCalendarNotificationTrigger` with a 14-day repeating interval and matching localized copy. |
| **`TEST-NOT-03`** | Unit | Reminder Cancellation | Active scheduled notification pending | Call `cancelReminders()` | Pending notification request is removed; `isReminderScheduled()` returns `false`. |
| **`TEST-NOT-04`** | Unit / Offline | Offline Execution | Simulator in airplane / offline mode | Execute scheduling and cancellation | Succeeds instantly with **0 network calls** and 0 latency. |

---

## 4. Acceptance Criteria
- [x] Notification service runs completely on-device without remote push servers.
- [x] Permission requests handle denied/restricted states gracefully without blocking app use.
- [x] Passes all 4 test assertions (`TEST-NOT-01` through `TEST-NOT-04`).
