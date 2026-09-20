# Design Rebase & UI Merge Conflict Notes

* **Branch**: `feature/education-module-import`
* **Source of Truth for Requirements**: Jayme's Written Directives (Figma Node `211:59`)
* **Base Architecture**: Native Swift 6 / iOS 17+ monorepo with SwiftData persistence, 360° donut geometry, dynamic assessment state machine, and 109 passing tests.

## Directive Status Matrix

| # | Directive Summary | Status | Test Status | Resolution Strategy / Conflict Notes |
|---|---|---|---|---|
| 1 | Streak pill -> "Days to Next Assessment" + calendar icon | Done (`bb9ff1a`) | Passed | Clean vector cutout with true alpha for 6 date slots |
| 2 | Sparkle icon in top navigation bar (except loading & action plan) | Done (`bb9ff1a`) | Passed | Universal HeaderNavBar placement between Chart and Profile |
| 3 | Survey Results header styled identically to Past Results (2 lines) | Done (`bb9ff1a`) | Passed | 28pt Bold Title + 13pt Regular Subtitle with 4pt spacing |
| 4 | Add forward arrows (`arrow.right`) to all blue "Next" buttons | Done | Passed | Added `trailingIcon` & `trailingAppIcon` to `PrimaryButton`, applied to Frames 04, 05, 06, 07 |
| 5 | Add left arrow (`arrow.left`) to "Back to Results" button | Done | Passed | Standardized `PrimaryButton(title: "Back to Results", icon: "arrow.left")` in Frame 58:3 |
| 6 | Center text on "Back to Results" button | Done | Passed | Verified Figma node 64:3 horizontal center alignment and SwiftUI maxWidth container |
| 7 | Pinned sticky bottom bars for forms and survey views | Done | Passed | Standardized pinned bottom bar container with divider across Welcome, Exercises, Survey Overview, Choose Relationships, Frequency, and Question |
| 8 | Add "Return to Home" button at bottom of Past Results | Done | Passed | Added `SecondaryButton(title: "Return to Home", appIcon: .home)` to bottom of `PastResultsView` |
| 9 | Add back button to Past Results top bar | Done | Passed | Configured `HeaderNavBar(showBackButton: true, onBack: { router.pop() })` in `PastResultsView` |
| 10 | Calendar icon on streak badge | Done (`bb9ff1a`) | Passed | Resolved in Directive 1 |
| 11 | 1-line description under Survey Overview heading | Done (`f3c820c`) | Passed | Added `"Review guidelines for your C.A.R.E. assessment."` (`Poppins Regular 13pt`) |
| 12 | Up to 2-line purpose descriptions on Choose Relationships, Survey Overview, Survey Questions | Done (`f3c820c`) | Passed | Added purpose subtitles to Choose Relationships (`Frame 17:4`), Survey Overview (`Frame 13:4`), and Survey Questions (`Frame 25:4`) |
| 13 | Restyle Sarah Mitchell on Survey Question (muted slate 22pt) | Done (`f3c820c`) | Passed | Restyled participant name in `Poppins SemiBold 20pt` with `#64748B` (`textSecondary`) under 26pt bold header |
| 14 | Interstitial participant transition card before survey for each person | Done (`1a52595`) | Passed | Implemented `PersonTransitionView` (`Frames 241:467 & 241:492`) displaying participant avatar, category/age pills, and description card before survey and between participants |
| 15 | Survey Question button "Submit", remove arrow, auto-advance, single-screen fit | Done (`62fe0e9`) | Passed | Button label set to `"Submit"` (or `"Complete Assessment"` on final question), arrow removed (`trailingIcon: nil`), auto-advance with 250ms delay, and 15.5pt/13pt compact typography fitting within single screen |
| 16 | Resume assessment button on Homepage (resume or discard) | Done (`7dbe5c3`) | Passed | Implemented `homepage-resume` (`Frame 244:470`) within Card 02 (`ActionCardView`) with "Resume" and "Discard" capsule pills when an assessment session is in progress |
| 17 | Action Plan page: "Wired to Connect" should link to Amy's Book purchase link, underline the text | Done | Passed | Formatted Dr. Amy Banks' book title in `PersonalizedActionPlanView` with underlined interactive `Link` to official book purchase URL |

## UI & Architecture Merge Conflicts Log

### Conflict 1: Directive #4 vs Directive #15 on SurveyQuestionView Primary CTA
- **Description**: Directive #4 mandated forward arrows (`arrow.right`) on all blue "Next" buttons. Directive #15 explicitly required that the button on `survey-question` should say `"Submit"` and have the arrow removed.
- **Resolution**: Directive #15 is a screen-specific override for `SurveyQuestionView`. Frames 04, 05, 06 retain `"Next →"`, while Frame 07 displays plain-text `"Submit"` (or `"Complete Assessment"` on the final question) with `trailingIcon: nil`.

### Conflict 2: Assessment Button Progression Invariant vs "Submit"
- **Description**: Model tests (`TEST-SCR-05`, `testSurveyQuestionButtonProgression`) expect `session.currentButtonTitle` on `AssessmentSessionState` to return `"Next: {Name}"` or `"Next"`.
- **Resolution**: Maintained `currentButtonTitle` on the model struct so all underlying unit tests pass. In `SurveyQuestionView`, the user-facing UI displays `"Submit"` for standard questions and `"Complete Assessment"` for the final question.

### Conflict 3: Homepage Resume UI Integration (`Frame 244:470`)
- **Description**: Jayme created a dedicated Figma frame `homepage-resume` (`Node 244:470`) showing the homepage when an assessment is in progress. In her older visual mockup, the canvas did not incorporate our latest dynamic SwiftData persistence or 4-line trend charts.
- **Resolution**: Rebased Jayme's semantic pattern onto our modern architecture: `ActionCardView` conditionally displays the exact `buttons-row` (`Node 244:560`) with "Resume" (pure white capsule, navy text) and "Discard" (frosted capsule, white text) in the footer of Card 02 (Assessment) whenever `activeSession.hasStarted` is true. Discarding cleanly purges the in-progress session and restores the default "Track Mind" subtitle.

### Conflict 4: Auto-Advance Delay vs Accessibility
- **Description**: Jayme requested that tapping an option automatically advances to the next question. However, instant transitions can disorient users or trigger accidental double-advances if a user quickly changes their choice.
- **Resolution**: Implemented a 250ms tactile delay with `selectedOption?.id == option.id` guard verification before advancing. This allows the user to see the selection state change visually and preserves HIG tap target response. Users can also tap "Submit" immediately.
