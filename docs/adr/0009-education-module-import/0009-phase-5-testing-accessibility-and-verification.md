# ADR 0009.5: Phase 5 — Testing, Accessibility Audit & Verification

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 5 executes the full testing verification suite, conducts an automated Apple VoiceOver accessibility audit across all 7 Education frames, and verifies end-to-end user navigation journeys via `XCUITest`.

### Architectural Deliverables
* **`CAREAppUITests` Extension**: Adds `testEducationModuleJourney` verifying the user flow:
  `HomeView` $\to$ `EducationTopicsView` $\to$ `TopicDetailView(RCT)` $\to$ `Complete Topic` $\to$ `Back to Hub`.
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
  -only-testing:CAREAppUITests/testEducationModuleJourney
```
