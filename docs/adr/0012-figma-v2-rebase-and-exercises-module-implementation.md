# ADR 0012: Figma V2 Rebase, Directives 18+, and Exercises Module Implementation

* **Status**: Accepted & Implemented (127/127 Tests Passed across 23 Suites)
* **Date**: 2026-09-26
* **Deciders**: Lead AI Systems Architect, Mobile Engineering Team, Product Design (Jayme)
* **Figma File**: `C.A.R.E. App` (Key: `4uqL8l0VygkDoFQeXP7VeL`, Canvas Nodes `239:8`, `302:3`, `470:671`)
* **Branch**: `feature/education-module-import`

---

## 1. Context & Motivation

Following the completion of Directives 1–17 (ADR 0011), product designer Jayme published a comprehensive set of additions, refinements, and full screen replacements directly onto the Figma canvas:
1. **Node `302:3` ("NEW SCREENS")**: Identifies colorized exercises, calm exercise sub-flows (video clips, photo reflection, belonging list, exercise complete celebration), personalized action plan exercises, cancellation/save pop-ups, and sort-by overlays.
2. **Node `239:8` ("Detailed Updates & Directives")**: Provides binding specifications for:
   * **`survey-results-v2` (`292:4`)**: Complete overhaul replacing `survey-results` (`29:4`), introducing redesigned score cards, info trigger to C.A.R.E. guide, swipeable relationship cards with search/filters, and exercise pathways.
   * **`past-results-v2` (`335:4`)**: Overhaul replacing `past-results` (`95:2`), introducing `"ASSESSMENT HISTORY"` pre-title, blue metric bubble showing Peak Score, Latest Score, and `% change vs last`, embedded category line charts, and relationship search & sort.
   * **`CARE information icon` (`372:50`)**: Dedicated interactive guide detailing the four C.A.R.E. domains (Calm, Acceptedness, Resonance, Energy) with tabbed navigation and static score brackets (Good 95–125, Moderate 70–94, Low <70).
   * **`add-relationship` (`281:4`)**: Standalone contact addition screen.
   * **Existing Screen Polish**: 7-day weekly exercise tracker on `HomeView`; removal of redundant "Sarah Mitchell" subtitle on `SurveyQuestionView`; light "Cancel" button on `ProfileView`; global subtle header line; button background color rules (white for "Return to Home" & "Back to Results", blue for "Next" & "View All Exercises").

---

## 2. MECE Architectural Decomposition

To ensure strict Mutually Exclusive, Collectively Exhaustive (MECE) coverage, implementation is broken down into five distinct phases:

### Phase 1: Design Tokens, Global Components & Existing Screen Polish
* **Token Standardization**:
  * Add 0.5pt subtle divider (`#E2E8F0`) below `HeaderNavBar`.
  * Ensure `Buttons.swift` enforces white backgrounds for `.secondary` ("Return to Home", "Back to Results") and blue `#2563EB` for `.primary` ("Next", "View All Exercises").
* **Screen Refinements**:
  * `HomeView`: Add 7-day weekly exercise completion bar at top; retain "Days to Next Assessment" while cleaning up legacy streak elements.
  * `SurveyQuestionView`: Remove "Sarah Mitchell" subtitle cleanly (interstitial cards now introduce participants).
  * `ProfileView`: Style bottom button as light "Cancel".

### Phase 2: Overlays, Modals & Shared Bottom Sheets
* `CancelChangesConfirmationView` (`415:1014`): Confirmation dialog preventing accidental loss of contact or profile edits.
* `SaveAssessmentConfirmationView` (`419:489`): Dialog prompting user to save or discard in-progress assessment.
* `RelationshipSortSheet` (`422:905`): Detented bottom sheet supporting 5 sort criteria: Most Recent, Most Completed Assessments, Highest Overall Score, Relationship Type, Age.
* `ExerciseSortSheet` (`427:98`): Detented bottom sheet supporting 5 sort criteria: Most Recently Completed, Times Completed, Highest Rated, Longest Duration, Shortest Duration.

### Phase 3: Information Guide & Contact Management Screens
* `CAREInformationView` (`372:50`): Interactive guide with segmented/tabbed switcher for Calm, Accepted, Resonant, and Energetic domains, mapping neurobiological systems and score brackets.
* `AddRelationshipView` (`281:4`): Full-page form with avatar upload, full name, age, and 12-category relationship type picker, integrating with `ContactsRepositoryProtocol`.

### Phase 4: Full Exercises Module & Sub-Flows
* **Data Models & State**: `Exercise`, `ExerciseCategory`, `ExerciseSessionState`, `BelongingItem`.
* `CalmExercisesView` (`270:4`): Calm dashboard with search bar, filter tabs (`All`, `Favorites`, `Recent`, `Most Used`), 3-day streak card, and exercise cards.
* `WatchFunnyExerciseView` (`275:4`): Video clip selection and playback exercise.
* `KeepPhotoExerciseView` (`275:1237`): Somatic grounding exercise with Camera Roll image reflection.
* `BelongingListExerciseView` (`286:4`): 5-item structured text inventory.
* `CAREResultsExercisesView` (`288:4`): Tailored pathways, relational strengths, areas to nurture, and recommended exercises.
* `ExerciseCompleteView` (`290:4`): Milestone celebration, streak updates, 5-star rating, and next exercise recommendations.

### Phase 5: V2 Screen Replacements & Route Wiring
* `SurveyResultsV2View` (`292:4`): Modular replacement for `SurveyResultsView`.
* `PastResultsV2View` (`335:4`): Modular replacement for `PastResultsView` with dynamic math (`peakScore`, `latestScore`, `percentageChangeVsPrevious`).
* `AppRoute`: Register new routes while maintaining backward-compatible aliases.

---

## 3. MECE Test Suite Verification Strategy

Every phase requires an accompanying test suite acting as the loop exit gate:
1. `CAREDesignTokensAndPolishTests`: Verifies button color invariants, header divider presence, subtitle removal on questions, and profile cancel CTA.
2. `OverlaysAndSheetsTests`: Verifies sort enum ordering, filtering logic, and modal confirmation action dispatching.
3. `CAREInformationAndContactsTests`: Verifies domain tab selection, score bracket boundaries, and contact creation persistence.
4. `ExercisesModuleTests`: Verifies exercise search filtering, completion state progression, rating recording, and streak math.
5. `V2ResultsAndTrendsTests`: Verifies peak score calculation, % delta calculation vs previous session, empty/single session edge cases, and swipeable contact queries.

---

## 4. Invariant Governance
1. Zero regressions on existing 105+ unit and UI tests.
2. Swift 6 strict concurrency (`@Observable`, `@MainActor`, `Sendable`) with 0 warnings.
3. Decoupled routing preserving human UX inspection readiness.
