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
   * `.educationDetail(EducationTopic)`: Navigates to `TopicDetailView(topic:)`.
2. **Homepage Dashboard Entry Card (`Views/HomeView.swift`)**:
   * Wire the existing **"Education / Relational Theory"** dashboard widget to push `.education` onto the navigation stack.
3. **`EducationProgressRepositoryProtocol` (`Repositories/EducationProgressRepositoryProtocol.swift`)**:
   * Tracks completed reading topics in local storage so users can see visual checkmarks on topics they have finished.
   * `MockEducationProgressRepository` for deterministic preview and unit tests.

---

## 2. SOTA Test Specification Matrix (`EducationNavigationTests.swift` & `EducationProgressTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDN-01`** | Nav | Home to Education Hub Route | AppRouter at root | `router.navigate(to: .education)` | `router.path` contains `.education` route. |
| **`TEST-EDN-02`** | Nav | Education Hub to Topic Detail | AppRouter at `.education` | `router.navigate(to: .educationDetail(topic))` | `router.path` contains detail route with target topic. |
| **`TEST-EDN-03`** | Nav | Deep Link & Pop to Root | Deep inside detail view | `router.popToRoot()` | Resets path to root `HomeView` with 0 memory leaks. |
| **`TEST-EDN-04`** | Nav | HeaderNavBar Chart & Profile | Inside Education screen | Tap Chart / Profile | Correctly opens Past Results or Storage Settings modal. |
| **`TEST-EDP-01`** | Progress | Mark Topic Complete | Topic unread | `repo.markTopicCompleted(topicId)` | Repository reflects completed status and emits update. |
| **`TEST-EDP-02`** | Progress | Persistence & Reset | 3 topics completed | `repo.resetProgress()` | All progress cleared to unread state. |

---

## 3. Acceptance Criteria
- [ ] HomeView dashboard "Education" button navigates directly to `EducationTopicsView`.
- [ ] Topic cards navigate seamlessly to respective detail screens and pop back cleanly.
- [ ] Passes all 6 navigation and progress test assertions.
