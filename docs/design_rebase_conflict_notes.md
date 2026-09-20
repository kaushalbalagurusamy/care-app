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
| 8 | Add "Return to Home" button at bottom of Past Results | Pending | Pending | |
| 9 | Add back button to Past Results top bar | Pending | Pending | |
| 10 | Calendar icon on streak badge | Done (`bb9ff1a`) | Passed | Resolved in Directive 1 |
| 11 | 1-line description under Survey Overview heading | Pending | Pending | |
| 12 | Up to 2-line purpose descriptions on Choose Relationships, Survey Overview, Survey Questions | Pending | Pending | |
| 13 | Restyle Sarah Mitchell on Survey Question (muted slate 22pt) | Pending | Pending | |
| 14 | Interstitial participant transition card before survey for each person | Pending | Pending | |
| 15 | Survey Question button "Submit", remove arrow, auto-advance, single-screen fit | Pending | Pending | |
| 16 | Resume assessment button/banner on Homepage (resume or discard) | Pending | Pending | |

## UI & Architecture Merge Conflicts Log
*(Populated during execution as conflicts are evaluated and resolved)*
