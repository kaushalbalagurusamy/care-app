# ADR 0009.4: Phase 4 — Navigation Routing, Dashboard Entry & Progress Tracking

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 4 wires the Education screens into the app's root navigation stack, connects the Homepage "Education" dashboard widget, and tracks reading progress locally.

### Architectural Deliverables
1. **`AppRoute` Navigation Cases (`Navigation/AppRouter.swift`)**:
   * `.education`: Navigates to `EducationTopicsView`.
   * `.educationDetail(topic: EducationTopic)`: Navigates to `TopicDetailView(topic:)`.
2. **Homepage Dashboard Entry Card (`Views/HomeView.swift`)**:
   * Wire the existing **"Education / Relational Theory"** dashboard widget to push `.education` onto the navigation stack.
3. **`EducationProgressRepositoryProtocol` (`Repositories/EducationProgressRepositoryProtocol.swift`)**:
   * Tracks completed reading topics in local storage so users can see visual checkmarks on topics they have finished.
   * `MockEducationProgressRepository` for deterministic preview and unit tests.

---

## 2. SOTA Test Specification Matrix (`EducationNavigationTests.swift` & `EducationProgressTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDN-01`** | Nav / Routing | Home Dashboard $\to$ Education Hub | AppRouter at `.home` | Tap "Education" dashboard action card | `router.path.count == 1` and active route equals `.education`. |
| **`TEST-EDN-02`** | Nav / Routing | Education Hub $\to$ Topic Detail | AppRouter at `.education` | Tap Topic 0 (RCT) | `router.path.count == 2` and active route equals `.educationDetail(topic: rctTopic)`. |
| **`TEST-EDN-03`** | Nav / NavigationBar | Standardized Top Bar Actions | Inside `TopicDetailView` | Tap Back, Home, Chart, Profile | Back pops 1 level; Home pops to root; Chart navigates to Past Results; Profile opens Storage Settings modal. |
| **`TEST-EDP-01`** | Progress / Persistence | Mark Topic as Read | Unread topic in `EducationProgressRepository` | Call `markTopicCompleted(slug:)` | Topic is marked completed; persistent store is updated; Hub displays green checkmark badge. |
| **`TEST-EDP-02`** | Progress / Erasure | Right-to-Erasure Full Purge | 6 completed topics stored | Call `resetProgress()` or trigger Storage Clear All | All topic completion states reset to unread (`completedCount == 0`). |

---

## 3. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationNavigationTests
```
