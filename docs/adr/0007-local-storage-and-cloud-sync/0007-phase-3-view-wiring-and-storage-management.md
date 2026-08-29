# ADR 0007.3: Phase 3 — View Data Wiring, User Storage Management & Erasure

* **Status**: Completed / Verified
* **Date**: 2026-08-28 (Updated 2026-08-29)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 3 wires the live repository to the SwiftUI views across Frames 5, 7, 8, and 10. It introduces user-facing storage management controls: swipe-to-delete on contacts and past assessment cards, a real-time storage usage meter, and a one-tap full data purge action.

### Architectural Deliverables & Completion Checklist
- [x] **Frame 5 (`ChooseRelationshipsView`) Wiring**:
  - Replaces static rolodex with live `ContactsRepository.fetchContacts()`.
  - Added custom contact creation sheet and dynamic contact additions.
- [x] **Frame 7 & 8 (`SurveyQuestionView` / `ContentView`) Persistence**:
  - Automatically persists completed `AssessmentResult` to `AssessmentRepository.saveAssessmentResult()`.
- [x] **Frame 10 (`PastResultsView`) Dynamic Timeline**:
  - Loads real historical assessments via `AssessmentRepository.fetchAssessmentHistory()`.
  - Added delete actions on historical assessment sessions with real-time recalculation.
- [x] **Storage Management Sheet (`Views/StorageSettingsView.swift`)**:
  - Real-time storage readout: `"Storage Used: ~142 KB (18 / 50 sessions stored) • Synced via iCloud"`.
  - One-tap `"Clear All Assessment History"` button with confirmation prompt (Right to Erasure compliance).
- [x] **Automated Test Verification (`StorageManagementTests.swift`)**:
  - 4 unit & state assertions (`TEST-MGT-01` through `TEST-MGT-04`) passing with 100% success rate.

---

## 2. User Storage Management Controls

```
┌─────────────────────────────────────────────────────────────┐
│                 Storage & Data Privacy                      │
├─────────────────────────────────────────────────────────────┤
│ Storage Used: 214 KB                                        │
│ Saved Assessments: 18 / 50                                  │
│ Saved Contacts: 12 / 50                                     │
│ Sync Status: Synced with Private iCloud                     │
├─────────────────────────────────────────────────────────────┤
│ [ Delete All Historical Assessments ]                       │
│ [ Reset Entire App Data ]                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. SOTA Test Specification Matrix (`StorageManagementTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-MGT-01`** | Unit / ViewState | Frame 5 Contact Deletion | 5 contacts active in rolodex | User deletes 1 contact via repository | Contact count decrements to 4; deleted contact disappears from selection grid. |
| **`TEST-MGT-02`** | Unit / ViewState | Frame 10 Past Results Deletion | 4 historical assessments in timeline | User deletes 1 historical assessment session | Assessment is purged from disk; historical trendline chart points recalculate immediately. |
| **`TEST-MGT-03`** | Unit / Erasure | Complete Data Purge | Container contains 25 sessions and 10 contacts | Execute `clearAllHistory()` | **Right to Erasure Invariant**: All assessment sessions and participant scores are zeroized (`count == 0`). |
| **`TEST-MGT-04`** | Unit | Storage Readout Formatter | Container with 18 stored sessions (~90 KB) | Query `calculateStorageUsage()` | Formats human-readable storage string: `"142 KB (18 / 50 sessions stored)"`. |

---

## 4. Acceptance Criteria
- [x] Completing a survey saves the session to disk, immediately reflected in Frame 10.
- [x] Deleting an assessment in Frame 10 smoothly recalculates trendline coordinates.
- [x] Passes all 4 test assertions (`TEST-MGT-01` through `TEST-MGT-04`).
