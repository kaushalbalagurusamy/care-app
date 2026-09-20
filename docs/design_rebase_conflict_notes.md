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
| 11 | 1-line description under Survey Overview heading | Done | Passed | Added `"Review guidelines for your C.A.R.E. assessment."` (`Poppins Regular 13pt`) |
| 12 | Up to 2-line purpose descriptions on Choose Relationships, Survey Overview, Survey Questions | Done | Passed | Added purpose subtitles to Choose Relationships (`Frame 17:4`), Survey Overview (`Frame 13:4`), and Survey Questions (`Frame 25:4`) |
| 13 | Restyle Sarah Mitchell on Survey Question (muted slate 22pt) | Done | Passed | Restyled participant name in `Poppins SemiBold 20pt` with `#64748B` (`textSecondary`) under 26pt bold header |
| 14 | Interstitial participant transition card before survey for each person | Done | Passed | Implemented `PersonTransitionView` (`Frames 241:467 & 241:492`) displaying participant avatar, category/age pills, and description card before survey and between participants |
| 15 | Survey Question button "Submit", remove arrow, auto-advance, single-screen fit | Pending | Pending | |
| 16 | Resume assessment button/banner on Homepage (resume or discard) | Pending | Pending | |

## UI & Architecture Merge Conflicts Log
*(Populated during execution as conflicts are evaluated and resolved)*
