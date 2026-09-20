# CARE App Progress Report: Design Directives #1–17 & Handoff Brief

* **Date**: September 20, 2026
* **Branch**: `feature/education-module-import`
* **Target Platforms**: iOS 17.0+ (Tested on iPhone 16 Pro, Simulator iOS 26.5 / arm64)
* **Status**: **Phase Complete** — All 17 Directives Implemented, Verified, and Atomically Committed.
* **Architecture Reference**: [ADR 0011: Figma Design System Updates & Exercises Module Integration Architecture](file:///Users/kaushal/Projects/care-app/docs/adr/0011-assessment-updates-and-exercises-import-architecture.md)
* **Conflict Log**: [Design Rebase & UI Merge Conflict Notes](file:///Users/kaushal/Projects/care-app/docs/design_rebase_conflict_notes.md)

---

## 1. Executive Summary

During this autonomous session, all **17 UI, UX, and architectural directives** requested by Product Design (Jayme) across Figma Canvas Node `211:59`, Node `239:8`, and newly drafted frames (`homepage-resume` 244:470, `transition` 241:467/492) were successfully implemented.

Because Jayme's visual canvas branched from an earlier snapshot of the codebase prior to the SwiftData persistence and multi-series trendline sprint, we executed an **intelligent architectural rebase**: applying Jayme's functional requirements and visual styling on top of our production-grade architecture without regressing any state machine, scoring, or persistence capabilities.

### Key Milestones Achieved:
1. **100% Directive Completion**: Directives 1 through 17 are fully implemented and verified.
2. **Zero Regressions Across All Test Suites**:
   - **Unit Tests**: **111 / 111 tests passing** across 18 suites in 0.74s.
   - **UI Tests**: **6 / 6 end-to-end tests passing** in 119.5s.
   - **Compiler**: 0 errors, 0 warnings under Swift 6 strict concurrency.
3. **Atomic Commit History**: 10 clean, targeted commits created on `feature/education-module-import`.
4. **Structured Handoff**: Open questions and design conflicts documented for immediate pick-up.

---

## 2. Git Commit Log (`feature/education-module-import`)

```
8bf0abf feat(action-plan): directive 17 - underline and link Wired to Connect to book purchase
7dbe5c3 feat(home): directive 16 - resume or discard in-progress assessment
62fe0e9 feat(survey): directive 15 - submit button, auto-advance, single-screen fit
1a52595 feat(survey): directive 14 - add participant interstitial transition screen
f3c820c feat(design): directives 11-13 - add section subtitles and restyle participant name on question view
02f3198 feat(design): directives 8 & 9 - add return to home button and back button to past results
5bcfd5b feat(design): directive 7 - pin sticky bottom action bars on forms and survey screens
9425915 feat(design): directives 5 & 6 - add left arrow and center text on back to results button
b940856 feat(design): directive 4 - add forward arrows to all next buttons
bb9ff1a feat(design): directives 1-3 baseline - streak calendar icon, universal top bar sparkle, and 2-line results headers
```

---

## 3. Directives Status Matrix

| # | Directive Title | Source Node | Commit | Status | Architectural Resolution |
|---|---|---|---|---|---|
| **1** | Streak Badge -> Calendar Icon + "Days to Next Assessment" | `211:59` | `bb9ff1a` | Verified | Clean vector cutout with true alpha transparency displaying 6 interior date slots. Horizontally centered text. |
| **2** | Universal Top Bar Sparkle Icon | `211:59` | `bb9ff1a` | Verified | Standardized `HeaderNavBar` sparkle button between Chart and Profile icons (and on HomeView). Tapping navigates to `.personalizedActionPlan`. |
| **3** | Two-Line Results Header | `211:59` | `bb9ff1a` | Verified | Survey Results header styled identically to Past Results: 28pt Bold Title + 13pt Regular Subtitle with 4pt vertical spacing. |
| **4** | Forward Arrows on All Next Buttons | `211:59` | `b940856` | Verified | Extended `PrimaryButton` with `trailingIcon: String?` and `trailingAppIcon: AppIcon?`. Applied `arrow.right` to Frames 04, 05, 06. |
| **5** | Left Arrow on "Back to Results" | `211:59` | `9425915` | Verified | Added `icon: "arrow.left"` to `PrimaryButton` in `SurveyResultsExpandedView` (Frame 58:3). |
| **6** | Center Text on "Back to Results" Button | `211:59` | `9425915` | Verified | Ensured centered label alignment via `.frame(maxWidth: .infinity)`. |
| **7** | Universal Pinned Sticky Bottom Action Bar | `211:59` | `5bcfd5b` | Verified | Pinned bottom action container above home indicator across Welcome, Exercises, Survey Overview, Choose Relationships, Frequency, and Question views. |
| **8** | "Return to Home" Button on Past Results | `211:59` | `02f3198` | Verified | Added `SecondaryButton(title: "Return to Home", appIcon: .home)` to bottom of `PastResultsView`. |
| **9** | Back Button in Past Results Top Bar | `211:59` | `02f3198` | Verified | Configured `HeaderNavBar(showBackButton: true, onBack: { router.pop() })` in `PastResultsView`. |
| **10** | Calendar Icon on Streak Badge | `211:59` | `bb9ff1a` | Verified | Integrated directly into Directive #1 vector cutout asset. |
| **11** | 1-Line Description on Survey Overview | `211:59` | `f3c820c` | Verified | Added `"Review guidelines for your C.A.R.E. assessment."` (`Poppins Regular 13pt`, `#64748B`) under header. |
| **12** | Purpose Subtitles on Key Funnel Screens | `211:59` | `f3c820c` | Verified | Added concise purpose subtitles to Choose Relationships (Frame 17:4), Survey Overview (Frame 13:4), and Survey Questions (Frame 25:4). |
| **13** | Restyle Sarah Mitchell on Survey Question | `211:59` | `f3c820c` | Verified | Restyled participant name in `Poppins SemiBold 20pt` with `#64748B` (`textSecondary`) under 26pt bold question title. |
| **14** | Interstitial Participant Transition Card | `211:59` | `1a52595` | Verified | Created `PersonTransitionView` (`Frames 241:467 & 241:492`) displaying participant avatar, category/age pills, and description card before survey and between participants. |
| **15** | Survey Question "Submit" Button, Auto-Advance & Single-Screen Fit | `211:59` | `62fe0e9` | Verified | Button label set to `"Submit"` (or `"Complete Assessment"` on final question), arrow removed (`trailingIcon: nil`), 250ms auto-advance delay, and optimized typography (15.5pt/13pt) fitting within single screen. |
| **16** | Resume / Discard Assessment on Homepage | `244:470` | `7dbe5c3` | Verified | Implemented `homepage-resume` inside Card 02 (`ActionCardView`) with "Resume" (pure white pill, navy text) and "Discard" (frosted outline pill, white text) when an assessment session is in progress. |
| **17** | Link "Wired to Connect" to Book Purchase | `239:8` | `8bf0abf` | Verified | Formatted Dr. Amy Banks' book title in `PersonalizedActionPlanView` with underlined interactive `Link` to official publisher book purchase URL. |

---

## 4. UI & Architectural Merge Conflict Resolutions

Four notable conflicts arose from re-basing Jayme's changes onto the latest codebase:

1. **Directive #4 (Forward Arrows) vs Directive #15 (Remove Arrow on Survey Question)**:
   - *Conflict*: Directive #4 called for forward arrows on all blue "Next" buttons, but Directive #15 explicitly requested removing the arrow on `survey-question` and naming it `"Submit"`.
   - *Resolution*: Directive #15 was treated as a screen-specific override on `SurveyQuestionView`. Frames 04, 05, and 06 keep `"Next →"`, while Frame 07 displays plain-text `"Submit"` / `"Complete Assessment"`.
2. **Domain Invariant vs UI Button Label**:
   - *Conflict*: Domain tests (`TEST-SCR-05`) check `session.currentButtonTitle` returning `"Next"` or `"Next: {Name}"`.
   - *Resolution*: Preserved `currentButtonTitle` on `AssessmentSessionState` for state machine logic and test contract compliance, while presentation layer on `SurveyQuestionView` cleanly presents `"Submit"` / `"Complete Assessment"`.
3. **Homepage Resume Mockup vs SwiftData Architecture (`Frame 244:470`)**:
   - *Conflict*: Jayme's mockup used an older card visual without our dynamic 4-line trend charts or SwiftData session lifecycle.
   - *Resolution*: Rebased the exact `buttons-row` (`Node 244:560`) into Card 02 (`ActionCardView`) footer. When `activeSession.hasStarted == true`, it reveals "Resume" (pure white capsule, navy text) and "Discard" (frosted capsule, white text). Discarding purges the session and resets the card to "Track Mind".
4. **Auto-Advance Debounce vs HIG Accessibility Standards**:
   - *Conflict*: Instant zero-delay advancement disorients users and prevents recovering from accidental taps.
   - *Resolution*: Implemented a 250ms tactile delay with `selectedOption?.id == option.id` guard verification before advancing. This allows the selection animation to complete visibly and feels natural.

---

## 5. Test Verification Summary

### Unit Tests: 111 / 111 Passed (0.74s)
```bash
xcodebuild test -project ios/CAREApp.xcodeproj -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests
```
* **Coverage**: All 18 suites passing.
  - Phase 1: Education Content Models & Manifest Test Suite
  - Phase 2: Domain Models & Pluggable Scoring Test Suite
  - Phase 2: Psychoeducation Reusable Components Test Suite
  - Phase 2: Assessment Session & Multi-Person Progression Test Suite
  - Phase 2: App Router & Navigation State Test Suite
  - Phase 3: Reusable Atomic UI Components Test Suite
  - Phase 3: Education Screen Views Test Suite
  - Phase 4: Screen Views Test Suite (includes new tests `TEST-SCR-10` and `TEST-SCR-14`)
  - Phase 4: Education Progress Tracking Test Suite
  - Phase 4: Education Navigation Routing Test Suite
  - Phase 6.1: Repository Protocol Contracts & Dependency Injection Test Suite
  - Phase 6.2: SwiftData CloudKit Storage Engine & Capacity Limits Test Suite
  - Phase 6.3: User Storage Management & View Data Wiring Test Suite
  - Phase 6.5: Storage Benchmarks, Sync Fallbacks & E2E Test Suite
  - Biometric Authentication & App Lock Tests (ADR 0008)
  - FuzzyMatcher Search & Typo-Tolerance Test Suite

### UI Tests: 6 / 6 Passed (119.5s)
```bash
xcodebuild test -project ios/CAREApp.xcodeproj -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppUITests
```
* **Coverage**:
  - `testFullAssessmentJourney`: Full funnel from Home $\to$ Overview $\to$ Calibration $\to$ Questionnaire $\to$ Results.
  - `testPastResultsNavigation`: Past Results view, 4-line chart, swipeable carousel, and search filter.

---

## 6. Catalog of Open Questions for Product & Design Review

When picking up work in the next session, review the following design and architectural questions:

### 1. In-App Purchases (StoreKit) vs External Book Purchase Link (Directive #17)
* **Context**: `PersonalizedActionPlanView` links Dr. Amy Banks' book *"Wired to Connect"* to Penguin Random House. The bottom of the view also displays a `$9.99` "Purchase Now" button for a personalized workbook.
* **Questions**:
  1. Under Apple App Store Guideline 3.1.1, digital workbook content unlocked inside the app requires StoreKit In-App Purchases (IAP). Is the `$9.99` action intended as an Apple IAP for digital workbook content, or will it route to an external store?
  2. For the book link: Should it launch Mobile Safari directly, or present an in-app `SFSafariViewController` sheet to prevent losing user context?

### 2. Auto-Advance Accessibility & User Customization (Directive #15)
* **Context**: 250ms debounce delay is currently hardcoded before advancing upon option selection.
* **Questions**:
  1. Is 250ms comfortable for all user cohorts, or should it be adjusted to 300–400ms?
  2. Should we add an accessibility toggle in Settings to allow users to disable auto-advance and require explicit taps on `"Submit"`?

### 3. Interstitial Participant Transition Automation (Directive #14)
* **Context**: `PersonTransitionView` requires an explicit tap on "Begin Questionnaire" or "Next Participant".
* **Questions**:
  1. Should this transition remain strictly manual, or offer an optional 3-second auto-advance countdown ring?
  2. Would design like a card-flip or slide transition between participants?

### 4. Long-Term Destination of Top Bar Sparkle Icon (Directive #2)
* **Context**: The sparkle icon currently navigates to `.personalizedActionPlan`. Jayme noted this may eventually map to a "Customization" screen.
* **Questions**:
  1. What is the intended destination once the Customization module is designed?
  2. What empty state should `PersonalizedActionPlanView` display if a user taps the sparkle before taking any assessment?

### 5. Multi-Line Chart & Carousel vs Static Visual Mockups (Design Rebase)
* **Context**: Jayme's mockups used a 1-line chart and simple static cards. Sprint 6/7 implemented a richer 4-line `CARETrendChart` and swipeable 5-dot carousel.
* **Questions**:
  1. Does design approve keeping the 4-line chart and 5-dot carousel as the production design, applying only visual styling (colors, typography, margins)?
  2. Or does design prefer a segmented toggle between "Aggregate Score" and "4-Pathway Breakdown"?

### 6. Assessment Session Persistence Across App Cold Starts (Directive #16)
* **Context**: In-progress assessment state currently lives in memory during the app session.
* **Questions**:
  1. Should in-progress draft answers be saved to SwiftData so users can resume after force-closing or restarting their phone?
  2. What is the expiration policy (e.g., auto-discard drafts older than 7 days)?

### 7. Layout Density on Compact Form Factors (iPhone SE)
* **Context**: Single-screen fit for `SurveyQuestionView` is calibrated for iPhone 16 Pro (393x852).
* **Questions**:
  1. On iPhone SE (375x667), the options will naturally scroll. Is vertical scrolling on compact devices acceptable, or should typography/padding scale down dynamically?

---

## 7. How to Pick This Up in the Next Session

1. **Verify Git State**:
   ```bash
   cd /Users/kaushal/Projects/care-app
   git status
   # Ensure branch is feature/education-module-import and working tree is clean
   ```
2. **Push Local Commits to Remote**:
   ```bash
   git push origin feature/education-module-import
   ```
3. **Execute Full Test Suite**:
   ```bash
   xcodebuild test -project ios/CAREApp.xcodeproj -scheme CAREApp \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     -only-testing:CAREAppTests
   ```
4. **Next Phase: Visual Pixel-Matching Pass**:
   - Align typography, padding, corner radii, and drop shadows across Frames 01–10 and Frames 19–22 against Jayme's Figma specs while preserving the architectural resolutions documented above.
