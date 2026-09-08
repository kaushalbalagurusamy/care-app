# ADR 0009.5: Phase 5 — Testing, Accessibility Audit & Verification

* **Status**: Accepted
* **Date**: 2026-09-05 (Updated & Accepted 2026-09-08)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 5 executes the full testing verification suite, conducts an automated Apple VoiceOver accessibility audit across all 8 Education frames, and verifies end-to-end user navigation journeys via `XCUITest`.

### Architectural Deliverables
* **`CAREAppUITests` Extension**: Adds `testEducationModuleJourney` verifying the user flow:
  `HomeView` $\to$ `EducationTopicsView` $\to$ `TopicDetailView(RCT)` $\to$ `Test Your Understanding` $\to$ `EducationQuizView` $\to$ `Return to Topic` $\to$ `Back to Hub`.
* **Accessibility (A11y) Matrix**:
  * VoiceOver labels and accessibility traits on all topic cards and actionable buttons.
  * Minimum 44pt × 44pt touch targets on all interactive components.
  * Full Dynamic Type scaling compliance on iOS 17+.

---

## 2. SOTA Test Specification Matrix (`CAREAppUITests`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDUI-01`** | UI Automation | E2E Reader User Journey | App booted on iPhone 16 Pro simulator | Home $\to$ Tap Education $\to$ Select RCT $\to$ Scroll to 5 Good Things $\to$ Tap Complete | Verifies element existence at each step; completes journey in $< 15\text{s}$; returns to Hub with checkmark. |
| **`TEST-EDUI-02`** | UI Automation | VoiceOver Accessibility Audit | App on Education Hub & Detail screens | Call `app.performAccessibilityAudit()` (iOS 17+) | **0 accessibility violations** (passes all contrast, element description, and touch target rules). |

---

## 3. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppUITests/testEducationModuleJourney \
  -only-testing:CAREAppUITests/testEducationModuleAccessibilityAudit
```

---

## 4. Verification Results (2026-09-08)
* **Suite**: `CAREAppUITests` (5/5 Passed, 2 new Education UI tests)
  * `TEST-EDUI-01`: `testEducationModuleJourney` — Full end-to-end reader journey (Home $\to$ Education Hub $\to$ RCT Detail $\to$ Test Your Understanding $\to$ Quiz Flow $\to$ Return to Topic $\to$ Back to Hub) — **PASSED**
  * `TEST-EDUI-02`: `testEducationModuleAccessibilityAudit` — Apple Automated Accessibility Audit (`app.performAccessibilityAudit()`) on iOS 17+ on Education Hub and Topic Detail screens — **PASSED with 0 accessibility violations** (contrast, accessibility descriptions, dynamic type font curves, and minimum 44pt touch target invariants).
* **Screenshots Captured & Verified**:
  * `scratch/simulator_home.png` — Home Dashboard with Education ActionCard
  * `scratch/education_hub.png` — Education Topics View with 6 topics
  * `scratch/education_detail.png` — Relational-Cultural Theory Detail View
  * `scratch/education_quiz.png` — Relational-Cultural Theory Quiz View
* **Overall Test Baseline**: **94 / 94 tests passing with 0 failures** across all 18 test suites (89 unit/integration + 5 UI tests). Zero regressions.

