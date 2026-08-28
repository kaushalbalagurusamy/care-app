# ADR 0007.5: Phase 5 — Multi-Device Sync State, Storage Benchmarks & E2E Verification

* **Status**: Proposed
* **Date**: 2026-08-28
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 5 verifies multi-device CloudKit synchronization state management, executes automated storage footprint benchmarks, and runs end-to-end `XCUITest` user journeys for data deletion and reminder scheduling.

### Architectural Deliverables
1. **`SyncStatus` State Machine & Publisher**:
   * Observes CloudKit sync events (`.synced`, `.syncing`, `.offline`, `.iCloudDisabled`).
2. **Automated Storage Footprint Benchmarks**:
   * Verifies that maximum capacity (50 contacts + 50 sessions) strictly occupies $< 500\text{ KB}$.
3. **End-to-End `XCUITest` Workflows**:
   * Tests completing an assessment, navigating to Past Results, swiping to delete a historical card, and interacting with storage settings.

---

## 2. SOTA Test Specification Matrix (`SyncStateTests.swift` & `CAREAppUITests`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-SNC-01`** | Unit / State | `SyncStatus` Lifecycle | Monitor `SyncStatus` publisher | Transition through iCloud available, syncing, and synced states | Emits correct status events for UI status indicators. |
| **`TEST-SNC-02`** | Unit / Fallback | iCloud Disabled Fallback | Device with iCloud signed out | Execute save and fetch operations | Repository operates seamlessly in local-only offline mode with 0 errors. |
| **`TEST-SNC-03`** | Unit / Conflict | Last-Write-Wins (LWW) | Two concurrent edits to the same contact name with different timestamps | Simulate CloudKit merge resolution | Newer timestamp edit is retained deterministically. |
| **`TEST-UI-01`** | UI Automation | Live Save & History View | Complete 20-Q survey journey | Navigate to `PastResultsView` (Frame 10) | Newly completed assessment appears at the top of the history list with accurate score. |
| **`TEST-UI-02`** | UI Automation | Swipe-to-Delete Journey | App at `PastResultsView` with past records | Perform swipe-left gesture on an accordion card and tap Delete | Card animates away; remaining count decrements; app does not crash. |
| **`TEST-UI-03`** | UI Automation | Storage Settings & Reminder Toggle | Open Storage & Reminder Settings | Toggle bi-weekly reminder switch and inspect storage meter | UI updates switch state and displays formatted KB usage string. |

---

## 3. Acceptance Criteria
- [ ] Multi-device sync gracefully falls back to local-only mode when iCloud is unavailable.
- [ ] Total disk footprint strictly complies with the $< 500\text{ KB}$ ceiling.
- [ ] Passes all 6 test assertions (`TEST-SNC-01` through `TEST-SNC-03`, `TEST-UI-01` through `TEST-UI-03`).
