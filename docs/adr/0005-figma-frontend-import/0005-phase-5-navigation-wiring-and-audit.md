# ADR 0005.5: Phase 5 — Navigation Wiring, Simulator Testing & Accessibility Audit

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

In this final phase, the individual components, models, and screen views are wired into [`ContentView.swift`](file:///Users/kaushal/Documents/Github/care-app/ios/CAREApp/ContentView.swift) using `NavigationStack(path:)`. End-to-end integration is verified through full compiler validation, automated `XCUITest` user journeys, and Apple VoiceOver accessibility audits under `ios/CAREAppUITests/`.

### Architectural Deliverables
1. **Root Navigation Routing (`ContentView.swift`)**: Type-safe navigation mapping every `AppRoute` to its screen view.
2. **End-to-End XCUITest Suite (`ios/CAREAppUITests/CAREAppUITests.swift`)**: Automated UI automation testing complete user journeys across all 10 Figma frames.
3. **Accessibility Audit Matrix**: VoiceOver accessibility traits, minimum 44pt touch targets, and Dynamic Type compliance across all screens.
4. **Clean Compilation Enforcement**: 0 compiler warnings, 0 deprecations, and Swift 6 concurrency validation via `XcodeBuildMCP`.

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppUITests/` and CI verification scripts:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-E2E-01`** | E2E UX | Full App Flow | Launch app on `Loading Screen` | Transition to Home -> Tap Start Assessment -> Configure Relationships -> Complete Survey -> View Results | Successfully lands on `SurveyResultsView` with score gauge visible; no crashes; all transitions complete within 500ms. |
| **`TEST-E2E-02`** | E2E UX | Past Results Journey | App launched at `HomeView` | Tap "View Past Results" -> Tap Date Filter -> Tap Accordion Card | Expands past assessment record; back button smoothly pops back to `HomeView`. |
| **`TEST-A11Y-01`** | Accessibility / VoiceOver | Full App Viewport | Enable Accessibility Audit mode (`XCUIApplication().performAccessibilityAudit()`) | Traverse all 10 screens | Passes standard Apple Accessibility Audit with 0 critical issues (e.g. missing labels, clipped text, insufficient touch targets). |
| **`TEST-A11Y-02`** | Accessibility / Dynamic Type | All Typography | Launch app with `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL` | Inspect rendered text bounding boxes | Text wraps cleanly to multiple lines without truncation (`...`) or layout overlaps. |
| **`TEST-BLD-01`** | Build / Concurrency | Project Workspace | Xcode 26+ toolchain | Execute `xcodebuild -project ios/CAREApp.xcodeproj -scheme CAREApp` with `-warnings-as-errors` | Compilation exits with return code `0` and 0 compiler warnings. |

---

## 3. Executable Test Contract (XCUITest Spec)

```swift
import XCTest

final class CAREAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testFullAssessmentJourney() throws {
        // 1. Loading Screen to Home
        let startButton = app.buttons["btn_start_assessment"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3.0), "Failed to transition from Loading to Home screen")
        startButton.tap()

        // 2. Assessment Overview to Survey Overview
        let overviewContinueButton = app.buttons["btn_overview_continue"]
        XCTAssertTrue(overviewContinueButton.waitForExistence(timeout: 2.0))
        overviewContinueButton.tap()

        // 3. Choose Relationships
        let partnerPill = app.buttons["pill_relationship_partner"]
        XCTAssertTrue(partnerPill.waitForExistence(timeout: 2.0))
        partnerPill.tap()
        
        let chooseContinueButton = app.buttons["btn_relationships_continue"]
        chooseContinueButton.tap()

        // 4. Relationship Frequency
        let frequencyContinueButton = app.buttons["btn_frequency_continue"]
        XCTAssertTrue(frequencyContinueButton.waitForExistence(timeout: 2.0))
        frequencyContinueButton.tap()

        // 5. Survey Questionnaire Stepper
        for _ in 1...5 {
            let optionCard = app.buttons["option_card_0"]
            XCTAssertTrue(optionCard.waitForExistence(timeout: 2.0))
            optionCard.tap()
            
            let nextButton = app.buttons["btn_survey_next"]
            nextButton.tap()
        }

        // 6. Survey Results
        let scoreBubble = app.otherElements["score_bubble_view"]
        XCTAssertTrue(scoreBubble.waitForExistence(timeout: 3.0), "Results screen failed to render score bubble")
    }

    func testAccessibilityAuditCompliance() throws {
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        }
    }
}
```

---

## 4. SDD Verification Loop Harness

To verify the E2E UX test suite autonomously on simulator runtime:
```bash
# Execute full UI test suite on iPhone 16 Pro Simulator
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppUITests
```
