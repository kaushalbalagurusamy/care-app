# ADR 0009.4: Phase 4 — Navigation Routing, Dashboard Entry & Progress Tracking

* **Status**: Accepted
* **Date**: 2026-09-05 (Updated & Accepted 2026-09-08)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 4 wires the Education screens into the app's root navigation stack, connects the Homepage "Education" dashboard widget, and tracks reading progress locally.

### Architectural Deliverables
1. **`AppRoute` Navigation Cases (`Navigation/AppRouter.swift`)**:
   * `.education`: Navigates to `EducationTopicsView`.
   * `.educationDetail(topic: EducationTopic)`: Navigates to `TopicDetailView(topic:)`.
   * `.educationQuiz(topic: EducationTopic)`: Navigates to `EducationQuizView(topic:)`.
2. **Homepage Dashboard Entry Card (`Views/HomeView.swift`)**:
   * Wire the existing **"Education / Relational Theory"** dashboard widget to push `.education` onto the navigation stack.
3. **`EducationProgressRepositoryProtocol` (`Repositories/EducationProgressRepositoryProtocol.swift`)**:
   * Tracks completed reading topics and passed quizzes in local storage so users can see visual checkmarks on topics they have finished.
   * `MockEducationProgressRepository` for deterministic preview and unit tests.
   * `LocalEducationProgressRepository` for UserDefaults-backed persistence.

---

## 2. SOTA Test Specification Matrix (`EducationNavigationTests.swift` & `EducationProgressTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDN-01`** | Nav / Routing | Home Dashboard $\to$ Education Hub | AppRouter at `.home` | Tap "Education" dashboard action card | `router.path.count == 1` and active route equals `.education`. |
| **`TEST-EDN-02`** | Nav / Routing | Education Hub $\to$ Topic Detail | AppRouter at `.education` | Tap Topic 0 (RCT) | `router.path.count == 2` and active route equals `.educationDetail(topic: rctTopic)`. |
| **`TEST-EDN-03`** | Nav / NavigationBar | Standardized Top Bar Actions | Inside `TopicDetailView` | Tap Back, Home, Chart, Profile | Back pops 1 level; Home pops to root; Chart navigates to Past Results; Profile opens Storage Settings modal. |
| **`TEST-EDN-04`** | Nav / Routing | Detail $\to$ Quiz $\to$ Return | Inside `TopicDetailView` | Tap "Test Your Understanding" $\to$ Tap Return | Pushes `.educationQuiz(topic:)`; return button pops cleanly back to `TopicDetailView`. |
| **`TEST-EDP-01`** | Progress / Persistence | Mark Topic as Read | Unread topic in `EducationProgressRepository` | Call `markTopicCompleted(slug:)` | Topic is marked completed; persistent store is updated; Hub displays green checkmark badge. |
| **`TEST-EDP-02`** | Progress / Erasure | Right-to-Erasure Full Purge | 6 completed topics stored | Call `resetProgress()` or trigger Storage Clear All | All topic completion states reset to unread (`completedCount == 0`). |
| **`TEST-EDP-03`** | Progress / Quiz | Record Quiz Success | Completed quiz | Call `recordQuizResult(slug:score:)` | Repository stores quiz pass state and timestamp. |


---

## 3. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationNavigationTests \
  -only-testing:CAREAppTests/EducationProgressTests
```

---

## 4. Verification Results (2026-09-08)
* **Suite 1**: `EducationNavigationTests` (4/4 Passed)
  * `TEST-EDN-01`: Home Dashboard to Education Hub navigation — **PASSED**
  * `TEST-EDN-02`: Education Hub to Topic Detail navigation — **PASSED**
  * `TEST-EDN-03`: Standardized Top Bar Actions operate router seamlessly — **PASSED**
  * `TEST-EDN-04`: Topic Detail to Quiz and return button flow — **PASSED**
* **Suite 2**: `EducationProgressTests` (3/3 Passed)
  * `TEST-EDP-01`: Mark topic as completed updates repository and count — **PASSED**
  * `TEST-EDP-02`: Right-to-Erasure full purge resets all progress — **PASSED**
  * `TEST-EDP-03`: Record quiz success updates quizPassed and completed state — **PASSED**
* **Project Total**: **92 / 92 tests passing** (89 unit/integration + 3 UI). Zero regressions across all 18 test suites.
