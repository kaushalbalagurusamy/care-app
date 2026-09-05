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
| **`TEST-EDUI-01`** | UI Automation | Complete Education Hub Journey | Launch app on simulator | Tap Education widget $\to$ Select RCT topic $\to$ Scroll through 5 Good Things | All sections render; scroll view is responsive; no crashes occur. |
| **`TEST-EDUI-02`** | UI Automation | VoiceOver Accessibility Audit | App on Education screens | Run `performAccessibilityAudit()` | Passes with 0 contrast or missing accessibility label violations. |

---

## 3. Acceptance Criteria
- [ ] 0 compiler warnings or deprecations.
- [ ] 100% of the planned 26 unit, component, screen, and UI tests pass.
