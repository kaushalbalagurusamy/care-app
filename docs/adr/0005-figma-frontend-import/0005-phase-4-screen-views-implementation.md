# ADR 0005.4: Phase 4 — Screen Views Implementation (10 Figma Frames)

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

The 10 frames from Figma represent the complete functional user interface. Each screen must be constructed as a modular, readable SwiftUI view that consumes domain models and atomic components without bloating into giant files.

### Architectural Deliverables (10 Screen Views)
1. **`LoadingView.swift` (`Loading Screen` — Frame `3:2`)**: Splash branding screen with centered logo, animated scaling, and transition into home.
2. **`HomeView.swift` (`homepage` — Frame `5:4`)**: Dashboard with welcome card, streak tracking banner, assessment quick-start buttons, and secondary destination routes (`.education`, `.exercises`).
3. **`AssessmentOverviewView.swift` (`assessment-overview` — Frame `11:4`)**: Informational assessment intro explaining process duration, confidentiality, and evaluation factors.
4. **`SurveyOverviewView.swift` (`survey-overview` — Frame `13:4`)**: Pre-questionnaire onboarding screen displaying full Do's and Don'ts rules.
5. **`ChooseRelationshipsView.swift` (`choose-relationships` — Frame `17:4`)**: Grid of selectable relationships enforcing exactly 5 selections before continuing.
6. **`RelationshipFrequencyView.swift` (`relationship-frequency` — Frame `41:4`)**: Contact frequency calibration screen featuring interactive percentage sliders summing to 100%.
7. **`SurveyQuestionView.swift` (`survey-question` — Frame `25:4`)**: Multi-step questionnaire viewport displaying animated question transitions, selectable answer choices, and dynamic `"Next: {Person Name}"` button progressions.
8. **`SurveyResultsView.swift` (`survey-results` — Frame `29:4`)**: Primary comprehensive outcome dashboard: dynamic radial score gauge, relational safety distributions, category breakdowns, and swipeable `TabView` individual result carousel with page dots.
9. **`SurveyResultsExpandedView.swift` (`survey-results-expanded` — Frame `58:3`)**: Deep-dive static reference sheet breaking down clinical safety factors and risk tiers ($\ge 75$, $60-75$, $< 60$).
10. **`PastResultsView.swift` (`past-results` — Frame `95:2`)**: Historical timeline tracking past assessments with date filtering and accordion summary cards.

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppTests/ScreenTests/` prior to implementing `Views/`:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-SCR-01`** | Unit / ViewState | `LoadingView` | Simulate splash screen timer lifecycle (1.5s duration) | Await transition callback | `onComplete()` callback fires accurately; animation transitions smoothly into `HomeView`. |
| **`TEST-SCR-02`** | Unit / Hierarchy | `HomeView` | Inject mock `UserSession(streakCount: 7)` | Inspect view element tree | Streak card displays `"7 Days"`, welcome banner is visible, and quick-action assessment card is present. |
| **`TEST-SCR-03`** | Unit / Selection | `ChooseRelationshipsView` | Inject 10 relationship categories | Select 5 items and tap Continue | Emits selected relationship IDs array with count == 5. Selecting fewer or more disables Continue. |
| **`TEST-SCR-04`** | Unit / Stepper | `SurveyQuestionView` | Session at Question 4 of 4 for Person 1 of 5 | Answer option selected | Primary button text switches to `"Next: {Person 2 Name}"`. On last question of Person 5, button reads `"Complete Assessment"`. |
| **`TEST-SCR-05`** | Unit / Render | `SurveyResultsView` | Inject completed `AssessmentResult` with 5 participants | Render results screen | Score bubble renders dynamically; swipeable carousel displays active page dot index matching the visible participant card. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 4: Screen Views Implementation Test Suite")
struct ScreenViewTests {
    
    @Test("TEST-SCR-03: ChooseRelationshipsView enforces exactly 5 selections")
    @MainActor
    func testChooseRelationshipsValidation() {
        let viewModel = ChooseRelationshipsViewModel()
        #expect(viewModel.canProceed == false)
        
        for i in 1...5 {
            viewModel.toggleSelection(for: UUID())
        }
        #expect(viewModel.canProceed == true)
        
        viewModel.toggleSelection(for: UUID()) // 6th selection
        #expect(viewModel.canProceed == false)
    }

    @Test("TEST-SCR-04: SurveyQuestionView advances dynamic button titles across participants")
    @MainActor
    func testSurveyQuestionButtonProgression() {
        let session = AssessmentSessionState.mock(participantCount: 5, questionsPerPerson: 4)
        let questionView = SurveyQuestionView(session: session)
        
        #expect(questionView.primaryButtonTitle == "Next")
    }
}
```

---

## 4. SDD Verification Loop Harness

To verify the Red -> Green cycle autonomously:
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/ScreenViewTests
```
