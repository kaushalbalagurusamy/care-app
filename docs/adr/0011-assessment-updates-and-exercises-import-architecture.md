# ADR 0011: Figma Design System Updates & Exercises Module Integration Architecture

* **Status**: Proposed / Pending Review & Hand Inspection
* **Date**: 2026-09-20
* **Deciders**: Lead AI Systems Architect, Mobile Engineering Team, Product Design (Jayme)
* **Figma File**: `C.A.R.E. App` (Key: `4uqL8l0VygkDoFQeXP7VeL`)
* **Design Handoff Scope**:
  * 10 Updated Assessment & Dashboard Frames (Frames 01–10)
  * 4 Brand-New Application Screens (Frames 19–22)
  * Jayme's 12 Canvas UI Directives (Figma Node `211:59`)

---

## 1. Context & Motivation

Following the successful implementation and verification of the Core Assessment engine (ADR 0005), Local-First Persistence & Sync (ADR 0007), Biometric App Lock (ADR 0008), and Psychoeducation & Clinical Neuroscience Module (ADR 0009), the mobile client maintains **105 passing tests across 18 test suites**.

Jayme has delivered a major design system refinement in Figma file `4uqL8l0VygkDoFQeXP7VeL`. Her updates encompass:
1. **12 Concrete UI Directives** (Figma Node `211:59`) refining existing assessment headers, subtitles, button positioning, and icon alignments.
2. **4 Brand-New Application Screens**:
   * `welcome-account-setup` (Node `213:4` | Frame 19)
   * `exercises-screen` (Node `214:4` | Frame 20)
   * `personalized-action-plan` (Node `215:5` | Frame 21)
   * `profile-page` (Node `218:4` | Frame 22)
3. **Canvas Routing Context**: On the Figma canvas, Jayme placed these exercise and onboarding screens on Page 1 (`[Done] Assessment & Homepage`, Node `0:1`) rather than the empty Page 3 (`Exercises`, Node `199:3`). In the application architecture, routing will remain cleanly decoupled under `AppRoute.exercises` and `ExercisesView`.

This ADR establishes the complete frame-by-frame integration plan, non-regression invariants, and testable acceptance criteria to govern the implementation run once hand inspection is complete.

---

## 2. Non-Regression Invariants

All changes must strictly preserve existing application features and pass all 105 tests:

1. **Assessment State Machine**: `AssessmentSessionState` answer tracking, `hasAnswerForCurrentQuestion`, `canAdvance`, multi-participant iteration, and dynamic button titles ("Next", "Next: {Name}", "Complete Assessment") must remain completely unmodified.
2. **Scoring Engine Integrity**: `FlexibleScoringEngine` domain score normalizations, clinical cutoffs (Safe $\ge 75$, Moderate 60–74, High Risk $< 60$), and `DonutChartView` angular geometry ($360.0^\circ \pm 0.001^\circ$) must remain byte-identical.
3. **Local-First Persistence**: SwiftData models (`StoredContact`, `StoredAssessmentSession`), CloudKit sync invariants, auto-pruning 50-session ceilings, and right-to-erasure GDPR/CCPA purges must not be broken.
4. **Search & Analytics**: `FuzzyMatcher` typo-tolerant candidate scoring, multi-series historical trendlines (`CARETrendChart`), and swipeable contact cards (`PageIndicatorDots`) must continue to render correctly.
5. **Swift 6 Strict Concurrency**: All views, components, and routers must compile with 0 warnings under Swift 6 strict concurrency (`@Observable`, `@MainActor`, `Sendable`).

---

## 3. Global Component & Design Token Enhancements

### A. Navigation Bar Sparkle & Calendar Icons (`HeaderNavBar.swift` & `AppIcon.swift`)
* Import Figma node `232:15` directly into `Assets.xcassets/icon_calendar.imageset/` and register `.calendar` in `AppIcon.swift`.
* Register `.sparkle` in `AppIcon.swift` with consistent 36x36 circular button styling (`CircularNavIconButton`).
* Update `HeaderNavBar.swift` with configurable sparkle button positioning:
  * **On Homepage (`HomeView`)**: Placed in the left cluster next to the Home pill / icon, matching the 8–10 pt horizontal spacing used between the stats and profile icons on the right.
  * **On Funnel Screens**: Placed in the right cluster alongside chart and profile icons.
  * **Excluded**: `LoadingView` and `PersonalizedActionPlanView`.
* Tapping the sparkle icon always routes to `AppRoute.personalizedActionPlan`.

### B. Standardized Primary & Secondary Button Icons (`Buttons.swift`)
* Extend `PrimaryButton` to support `trailingIcon: String?` (for right-facing arrows `arrow.right` on "Next" CTAs).
* Extend `PrimaryButton` and `SecondaryButton` to support centered text with leading icon (for `← Back to Results` and `← Return to Exercises`).
* Introduce `PrimaryDarkButton` for dark navy `#1E293B` buttons ("Unlock Full Book Exercises").
* Ensure all buttons preserve $\ge 44\text{ pt}$ HIG touch targets and haptic feedback.

### C. Universal Pinned "Sticky Bottom Action Bar" Pattern
Replace inline `ScrollView` buttons with a pinned bottom container:
```swift
VStack(spacing: 0) {
    HeaderNavBar(...)
    ScrollView {
        content
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    // Pinned above Home Indicator
    VStack(spacing: 8) {
        PrimaryButton(...)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(Theme.Colors.background.ignoresSafeArea(edges: .bottom))
}
```

---

## 4. Master Frame Catalog (22 Frames)

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             CARE App Master Frame Catalog (22 Frames)                            │
├─────────┬───────────────────────────────────────────┬──────────────┬─────────────┬───────────────┤
│ Frame # │ Frame Name                                │ Dimensions   │ Scope       │ Render File   │
├─────────┼───────────────────────────────────────────┼──────────────┼─────────────┼───────────────┤
│ 01      │ Loading Screen                            │ 390 × 844    │ Assessment  │ 01_loading..  │
│ 02      │ homepage                                  │ 390 × 844    │ Assessment  │ 02_homepage.. │
│ 03      │ assessment-overview                       │ 390 × 1045   │ Assessment  │ 03_assessment │
│ 04      │ survey-overview                           │ 390 × 844    │ Assessment  │ 04_survey_ov..│
│ 05      │ choose-relationships                      │ 390 × 844    │ Assessment  │ 05_choose_re..│
│ 06      │ relationship-frequency                    │ 390 × 844    │ Assessment  │ 06_relationsh.│
│ 07      │ survey-question                           │ 390 × 844    │ Assessment  │ 07_survey_qu..│
│ 08      │ survey-results                            │ 390 × 1842   │ Assessment  │ 08_survey_re..│
│ 09      │ survey-results-expanded                   │ 390 × 941    │ Assessment  │ 09_survey_re..│
│ 10      │ past-results                              │ 390 × 1467   │ Assessment  │ 10_past_resu..│
│ 11–18   │ Psychoeducation Module (8 Frames)         │ Multi        │ Education   │ 11_education..│
│ 19      │ welcome-account-setup                     │ 390 × 844    │ Account     │ 19_welcome_a..│
│ 20      │ exercises-screen                          │ 390 × 844    │ Exercises   │ 20_exercises..│
│ 21      │ personalized-action-plan                  │ 390 × 844    │ Action Plan │ 21_personali..│
│ 22      │ profile-page                              │ 390 × 844    │ Account     │ 22_profile_p..│
└─────────┴───────────────────────────────────────────┴──────────────┴─────────────┴───────────────┘
```

---

## 5. Frame-by-Frame Implementation & Acceptance Criteria

### Frame 01: Loading Screen (`3:2` | `01_loading_screen_frame_3_2.png`)
* **Inspection Status**: Identical to original design. No UI or layout changes required.
* **Asset Tracking**: Single canonical render retained as `docs/figma_frames/01_loading_screen_frame_3_2.png`.
* **Implementation Plan**: No code modifications needed. `LoadingView.swift` remains untouched.
* **Acceptance Criteria**:
  - [x] Canonical frame `01_loading_screen_frame_3_2.png` retained; redundant updated clone removed.
  - [x] Zero changes to `LoadingView.swift` logic or animation timing.
  - [x] `TEST-SCR-01` passes.

---

### Frame 02: Homepage & Dashboard (`5:4` | `02_homepage_frame_5_4.png`)
* **Inspection Status**: Implemented and verified on iOS Simulator. Retaining canonical render as `docs/figma_frames/02_homepage_frame_5_4.png`.
* **Key Architecture & Design Requirements**:
  1. **Direct Calendar Icon Asset Import**:
     * Extract Figma node `232:15` (`calendar-icon`) directly from Figma REST API at native vector / `@2x` / `@3x` resolution.
     * Store as a bundled asset in `Assets.xcassets/icon_calendar.imageset/` alongside existing icons (`icon_sparkles`, `icon_book_open`, `icon_heart_pulse`, `icon_activity`).
     * Expose through `AppIcon.calendar` and standalone `CalendarIcon` as a reusable component with `AppIcon_calendar` identifier and `"Calendar"` accessibility label.
  2. **Header Sparkle Icon Placement**:
     * Add the circular sparkle icon button (`AppIcon.sparkle`) into the **left header cluster next to the Home icon / pill**.
     * Enforce the exact same horizontal spacing (8–10 pt) that the stats (chart) and profile buttons have from each other on the right.
     * Tapping the sparkle icon navigates to `AppRoute.personalizedActionPlan`.
  3. **Assessment Interval Badge**:
     * In `StreakBadgeView` (or renamed `AssessmentIntervalBadgeView`), replace the previous sparkles icon with the new imported `calendar-icon`.
     * Update text to `"Days until next assessment: 3 days"`.
     * Horizontally center the icon and label within the 40 pt capsule container.
  4. **Card 03 Routing**:
     * Update Card 03 ("Exercises - Active Care") tap action to navigate directly to `AppRoute.exercises` (`ExercisesView`) instead of showing the placeholder alert.
* **Non-Regression Strategy**:
  * Preserve 350x196 aspect ratio on all 3 module cards, 3D render art backgrounds, and `ScaleCardButtonStyle`.
  * Preserve existing navigation stack transitions to `.education` (Card 01) and `.assessmentOverview` (Card 02).
* **Acceptance Criteria**:
  - [x] `icon_calendar` is imported into `Assets.xcassets` and reusable via `AppIcon.calendar` and `CalendarIcon`.
  - [x] Top navigation renders the sparkle button adjacent to the Home icon on the left with consistent 8–10 pt inter-icon spacing.
  - [x] Tapping the sparkle button navigates to `PersonalizedActionPlanView`.
  - [x] Tapping Card 03 routes to `ExercisesView`.
  - [x] Bottom pill renders calendar icon with centered `"Days until next assessment: 3 days"`.
  - [x] `TEST-SCR-02`, `TEST-SCR-02B`, `TEST-SCR-02C`, `TEST-CMP-07`, and `TEST-CMP-08` pass with 109/109 tests green.

---

### Frame 03: Assessment Overview (`11:4` | `03_assessment_overview_frame_11_4.png`)
* **Current Implementation**: `AssessmentOverviewView.swift`. Header, Title, Intro paragraph, "What is C.A.R.E.?", 4 domain cards (Calm, Accepted, Resonant, Energetic), "Begin the Survey" raw button.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included in the right icon cluster.
  2. Action Button: Standardize on `PrimaryButton` with 56 pt height and medium haptic feedback.
* **Non-Regression Strategy**:
  - Keep domain letter circles (48x48) and clinical explanations intact.
  - Maintain route to `AppRoute.surveyOverview`.
* **Acceptance Criteria**:
  - [ ] Header includes Back, Home on left; Chart, Sparkle, Profile on right.
  - [ ] "Begin the Survey" button uses `PrimaryButton` with 56 pt height and medium haptics.
  - [ ] All 4 C.A.R.E. domain explanations match clinical definitions.

---

### Frame 04: Survey Overview / Instructions (`13:4` | `04_survey_overview_frame_13_4.png`)
* **Current Implementation**: `SurveyOverviewView.swift`. "Survey Instructions", "Do:" (3 items), "Don't:" (3 items), raw "Next" button inside scroll view.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included in the right icon cluster.
  2. Subtitle: Add 1-line description below heading: `"Review guidelines for your C.A.R.E. assessment."`
  3. Action Button: Move "Next" button to pinned sticky bottom position, add forward arrow (`arrow.right`), 56 pt height.
* **Non-Regression Strategy**:
  - Preserve all 6 guidelines (Checkmark and Xmark styling).
  - Maintain route to `AppRoute.chooseRelationships`.
* **Acceptance Criteria**:
  - [ ] Subtitle `"Review guidelines for your C.A.R.E. assessment."` rendered in `Theme.Typography.poppins(.regular, size: 14)`.
  - [ ] "Next →" button is pinned to bottom above safe area.
  - [ ] Forward arrow icon displayed inside button.

---

### Frame 05: Choose Relationships (`17:4` | `05_choose_relationships_frame_17_4.png`)
* **Current Implementation**: `ChooseRelationshipsView.swift`. "Choose Relationships", "+ Add Person" button, list of contacts, sheet to add contact, inline "Next" button.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included.
  2. Subtitle: Add 2-line description: `"Choose the five relationships you'll reflect on in this C.A.R.E. assessment."`
  3. Action Button: Move "Next" to pinned sticky bottom position, add forward arrow (`arrow.right`), 56 pt height.
* **Non-Regression Strategy**:
  - Retain strict 5-contact selection guard (`isSelectionFull`, enabled only when exactly 5 contacts selected).
  - Retain live SwiftData integration (`contactsRepo.fetchContacts()`).
  - Retain Add Person modal validation (age > 0, required fields, `TEST-SCR-03B`).
  - Retain swipe-to-delete contact capability (`TEST-MGT-01`).
* **Acceptance Criteria**:
  - [ ] Subtitle rendered below title.
  - [ ] "Next →" button pinned to bottom edge, eliminating mid-screen float.
  - [ ] Button disabled when selection count != 5, enabled when count == 5.
  - [ ] `TEST-SCR-03`, `TEST-SCR-03B`, and `TEST-MGT-01` pass.

---

### Frame 06: Relationship Frequency Calibration (`41:4` | `06_relationship_frequency_frame_41_4.png`)
* **Current Implementation**: `RelationshipFrequencyView.swift`. "Choose Frequency", subtitle with trailing period, `VerticalTimeAllocationBubble`, raw "Next" button.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included.
  2. Subtitle: Remove trailing period: `"Drag the borders to estimate the percent time spent in each relationship"`
  3. Action Button: Standardize onto `PrimaryButton` with forward arrow (`arrow.right`), 56 pt height, pinned at bottom.
* **Non-Regression Strategy**:
  - Retain interactive multi-border draggable time allocation bubble summing to 100% (`TEST-SCR-04`).
  - Retain participant allocation mapping to `AssessmentParticipant`.
  - Retain session state initialization callback `onProceed`.
* **Acceptance Criteria**:
  - [ ] Subtitle text matches Figma exactly.
  - [ ] "Next →" button uses `PrimaryButton` with forward arrow.
  - [ ] Drag gesture continuously updates partition percentages and maintains 100% total.
  - [ ] `TEST-SCR-04` passes.

---

### Frame 07: Dynamic Survey Questionnaire (`25:4` | `07_survey_question_frame_25_4.png`)
* **Current Implementation**: `SurveyQuestionView.swift`. Header, "C.A.R.E. Assessment:" + participant name in identical bold fonts, progress bar & dual counter, dynamic prompt substituting person's name, 5-point Likert options, raw button.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included.
  2. Participant Name Restyling: Restyle participant name (e.g. "Sarah Mitchell") underneath "C.A.R.E. Assessment:" using distinct muted slate typography (`Theme.Typography.poppins(.semiBold, size: 22)` with `Color(hex: "#64748B")`).
  3. Subtitle: Add 2-line reflection guidance: `"Reflect on how you’ve felt in this relationship over the last 2 weeks."`
  4. Action Button: Move button to pinned sticky bottom position, add forward arrow (`arrow.right`), 56 pt height.
* **Non-Regression Strategy**:
  - **CRITICAL**: Retain progress bar and dual counter ("Person X of 5", "Question X of 20").
  - Retain dynamic question pronoun replacement (`formattedQuestionPrompt`).
  - Retain `AssessmentSessionState` progression state machine across all 20 questions and 5 participants.
  - Retain dynamic button title progression ("Next", "Next: James Cooper", "Complete Assessment") (`TEST-SCR-05`).
  - Retain automated scoring calculation and saving to `assessmentRepo` on completion.
* **Acceptance Criteria**:
  - [ ] "C.A.R.E. Assessment:" is bold 28pt; participant name is restyled in muted slate 22pt.
  - [ ] Subtitle `"Reflect on how you’ve felt in this relationship over the last 2 weeks."` rendered.
  - [ ] Progress bar and question counter remain fully functional.
  - [ ] Pinned bottom button displays forward arrow and updates dynamically.
  - [ ] `TEST-SCR-05` passes.

---

### Frame 08: Survey Results Comprehensive Dashboard (`29:4` | `08_survey_results_frame_29_4.png`)
* **Current Implementation**: `SurveyResultsView.swift`. Header, "Survey Results", Score Composition Donut Chart, Category Breakdown Accordion, Relational Safety Donut Chart, Results by Individual card with info icon, bottom buttons.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included.
  2. Subtitle: Add 1-line description: `"Review insights from your latest C.A.R.E. assessment"`
  3. Heading Parity: Ensure "Survey Results" heading matches formatting of "Past Results" (Poppins Bold 28pt).
  4. Bottom Buttons: Standardize "View Past Results" (`PrimaryButton`) and "Return to Home" (`SecondaryButton`).
* **Non-Regression Strategy**:
  - Retain exact 360° donut segment math and parallel slit rendering (`TEST-CMP-01`).
  - Retain clinical vagal tone accordion descriptions.
  - Retain navigation to `.surveyResultsExpanded` from Relational Safety info button.
  - Retain `latestResult` domain score bindings (`TEST-SCR-06`).
* **Acceptance Criteria**:
  - [ ] Header includes sparkle button and matches Past Results style.
  - [ ] Subtitle `"Review insights from your latest C.A.R.E. assessment"` rendered.
  - [ ] Both donut charts compute and render correct percentages.
  - [ ] `TEST-SCR-06` and `TEST-CMP-01` pass.

---

### Frame 09: Relational Risk Groups Deep Dive (`58:3` | `09_survey_results_expanded_frame_58_3.png`)
* **Current Implementation**: `SurveyResultsExpandedView.swift`. Header, "About Relational Risk Groups", 3 risk tier cards (Safe, Moderate Risk, High Risk), "Back to Results" `PrimaryButton`.
* **Jayme's Directives**:
  1. Header Bar: Sparkle icon included.
  2. Action Button: Add left back arrow icon (`arrow.left`) to "Back to Results" and ensure text is strictly centered.
* **Non-Regression Strategy**:
  - Retain clinical tier thresholds and safety advice.
  - Retain pop route back to `.surveyResults`.
* **Acceptance Criteria**:
  - [ ] Header includes sparkle icon.
  - [ ] Button displays `← Back to Results` with centered text and left-pointing arrow.
  - [ ] `TEST-SCR-07` passes.

---

### Frame 10: Historical Past Results & Relational Trends (`95:2` | `10_past_results_frame_95_2.png`)
* **Current Implementation**: `PastResultsView.swift`. Header, "Past Results", C.A.R.E. Results multi-trend chart, Relational Safety trend chart, Results by Individual with search bar, swipeable contact card carousel.
* **Jayme's Directives**:
  1. Header Bar: Add back button (`showBackButton: true`), plus sparkle icon.
  2. Subtitle: Add 1-line description: `"Compare results across your C.A.R.E. assessments"`
  3. Action Button: Add "Return to Home" button (`SecondaryButton`) at the bottom of the screen.
* **Non-Regression Strategy**:
  - Retain live SwiftData historical assessment query (`appEnvironment.assessmentRepo`).
  - Retain typo-tolerant `FuzzyMatcher` search bar.
  - Retain multi-series trendline graphics (`CARETrendChart`, `RelationalSafetyTrendChart`).
  - Retain swipeable `TabView` carousel with `PageIndicatorDots` (`TEST-SCR-08`, `TEST-SCR-09`).
  - Retain individual assessment deletion (`TEST-MGT-02`).
* **Acceptance Criteria**:
  - [ ] Back button in header pops back to previous screen.
  - [ ] Sparkle icon in header.
  - [ ] Subtitle `"Compare results across your C.A.R.E. assessments"` rendered.
  - [ ] "Return to Home" button at bottom pops to root.
  - [ ] `TEST-SCR-08`, `TEST-SCR-09`, `TEST-MGT-02` pass.

---

### Frame 19: Welcome & Account Setup (`213:4` | `19_welcome_account_setup_frame_213_4.png`) [NEW]
* **Purpose**: User onboarding and profile configuration.
* **Layout Specifications**:
  - Header: Back, Home on left; Chart, Sparkle, Profile on right.
  - Title: `"Welcome"` (Poppins Bold 30pt).
  - Subtitle: `"Let's finish setting up your account to start evaluating and tracking your relational health."`
  - Profile Avatar: Dashed circular container (80x80) with camera badge and `"Add Profile Photo"` text.
  - Text Fields: `"Full Name"` (placeholder: "e.g., Alex Johnson"), `"Age"` (placeholder: "e.g., 28").
  - Assessment Frequency: 5 pills (`2x/week`, `1x/week`, `biweekly` [with blue "RECOMMENDED" badge], `monthly`, `every 3 months`).
  - Bottom Action: Pinned `"Complete Setup"` `PrimaryButton` (56pt).
* **Architecture & State**:
  - Create `WelcomeAccountSetupView.swift` under `ios/CAREApp/Views/`.
  - Add `case welcomeAccountSetup` to `AppRoute`.
  - Save profile attributes into `UserProfile` model in `AppEnvironment`.
* **Acceptance Criteria**:
  - [ ] Full Name and Age fields accept input with standard validation.
  - [ ] Frequency pills toggle selection state, with `biweekly` selected by default.
  - [ ] "Complete Setup" saves user profile and navigates to `.home`.
  - [ ] Unit test verifies frequency selection and profile saving.

---

### Frame 20: Exercises Hub Screen (`214:4` | `20_exercises_screen_frame_214_4.png`) [NEW]
* **Purpose**: Core relational exercise hub strengthening neural pathways.
* **Layout Specifications**:
  - Header: Back, Home on left; Chart, Sparkle, Profile on right.
  - Title: `"Exercises"` (Poppins Bold 30pt).
  - Subtitle: `"Strengthen your relational neural pathways"`
  - 4 Pathway Cards:
    1. **Calm (C)**: "Fosters down-regulation of stress systems, developing neural pathways toward safety and emotional grounding."
    2. **Accepted (A)**: "Feeling valued, validated, and safely connected within healthy, supportive relationship cultures."
    3. **Resonant (R)**: "Activating mirror neurons to sense and dynamically align with another's emotional state without losing yourself."
    4. **Energetic (E)**: "The vitalizing emotional flow and neurochemical boost generated through growth-fostering, mutual bonds."
  - Bottom Action: Pinned `"Unlock Full Book Exercises"` dark navy button (`#1E293B`, 56pt) navigating to `PersonalizedActionPlanView`.
* **Architecture & State**:
  - Create `ExercisesView.swift` under `ios/CAREApp/Views/`.
  - Wire `case .exercises` in `ContentView.swift` to `ExercisesView(router: router)`.
  - Tapping pathway cards opens practice/exercise details; tapping the bottom button routes to `.personalizedActionPlan`.
* **Acceptance Criteria**:
  - [ ] 4 pathway cards render with circular letter badges (C, A, R, E) and chevron indicators.
  - [ ] Bottom dark button routes to `PersonalizedActionPlanView`.
  - [ ] Unit test verifies pathway card rendering and button navigation.

---

### Frame 21: Unlock Personalized Action Plan (`215:5` | `21_personalized_action_plan_frame_215_5.png`) [NEW]
* **Purpose**: Paywall & tailored guide based on C.A.R.E. scores.
* **Layout Specifications**:
  - Header: Back, Home on left; Chart, Profile on right (**NO sparkle icon** on this screen!).
  - Eyebrow: `"EXCLUSIVE SCIENCE-BACKED GUIDE"` (blue uppercase 13pt).
  - Title: `"Unlock Your Personalized Action Plan"` (Poppins Bold 26pt).
  - Pathways Map Card:
    - Sparkle icon + `"Your C.A.R.E. Pathways Map"` + `"TAILORED"` badge.
    - 4 domain score cards: Calm (18/125), Accepted (20/125), Resonant (15/125 - highlighted with active border), Energetic (22/125).
    - Focus Highlight: `"Focus Highlight: Your personalized plan places special emphasis on strengthening your Resonant Pathway based on your latest assessment."`
  - Book Description: Copy covering Dr. Amy Banks' "Wired to Connect", with checkmark bullet point.
  - Bottom Action: Stacked buttons:
    - `"Purchase Now — $9.99"` (`PrimaryButton` blue with credit card icon).
    - `"Return to Exercises"` (`SecondaryButton` outlined with `←` back arrow).
* **Architecture & State**:
  - Create `PersonalizedActionPlanView.swift` under `ios/CAREApp/Views/`.
  - Add `case personalizedActionPlan` to `AppRoute`.
  - Dynamic score binding: Injects scores from `latestResult` and automatically highlights the lowest scoring pathway as the Focus Highlight.
* **Acceptance Criteria**:
  - [ ] Sparkle icon is NOT present in the header bar.
  - [ ] 4 score cards reflect live assessment scores.
  - [ ] Lowest scoring pathway is highlighted dynamically with accent border and callout text.
  - [ ] "Return to Exercises" pops or navigates to `.exercises`.
  - [ ] Unit test verifies score calculation and lowest-pathway focus highlight logic.

---

### Frame 22: Profile Page (`218:4` | `22_profile_page_frame_218_4.png`) [NEW]
* **Purpose**: User account management and full access triggers.
* **Layout Specifications**:
  - Header: Back, Home on left; Chart, Sparkle on right.
  - Title: `"My Profile"` (Poppins Bold 30pt).
  - Avatar: Dashed circular placeholder with camera icon and `"Change Profile Photo"`.
  - Form: Full Name ("Alex Johnson"), Age ("28"), Assessment Frequency pills.
  - Bottom Actions (Stacked):
    - `"Save Changes"` (`PrimaryButton` blue, 56pt).
    - `"Unlock Full Book Exercises"` (`PrimaryDarkButton` navy `#1E293B`, 56pt).
* **Architecture & State**:
  - Create `ProfileView.swift` under `ios/CAREApp/Views/`.
  - Add `case profile` to `AppRoute`.
  - Update `HeaderNavBar` profile button to navigate to `.profile` (with a settings icon inside to access `StorageSettingsView`).
* **Acceptance Criteria**:
  - [ ] Full Name and Age are editable.
  - [ ] "Save Changes" updates stored user profile.
  - [ ] "Unlock Full Book Exercises" navigates to `PersonalizedActionPlanView`.
  - [ ] Unit test verifies profile state updates.

---

## 6. Execution Staging & Verification Matrix

```mermaid
flowchart TD
    subgraph S0["Stage 0: Foundation Tokens"]
        T1["AppIcon (.sparkle, .calendar)"]
        T2["Buttons (trailingIcon, PrimaryDarkButton)"]
        T3["HeaderNavBar (showSparkleButton)"]
    end

    subgraph S1["Stage 1: Existing Frames 01-10"]
        F2["Frame 02: HomeView"]
        F3["Frame 03: AssessmentOverview"]
        F4["Frame 04: SurveyOverview"]
        F5["Frame 05: ChooseRelationships"]
        F6["Frame 06: RelationshipFrequency"]
        F7["Frame 07: SurveyQuestion"]
        F8["Frame 08: SurveyResults"]
        F9["Frame 09: ResultsExpanded"]
        F10["Frame 10: PastResults"]
    end

    subgraph S2["Stage 2: New Frames 19-22"]
        F19["Frame 19: WelcomeAccountSetupView"]
        F20["Frame 20: ExercisesView"]
        F21["Frame 21: PersonalizedActionPlanView"]
        F22["Frame 22: ProfileView"]
    end

    subgraph S3["Stage 3: Verification & TDD Harness"]
        V1["Run CAREAppTests (105+ tests)"]
        V2["Add Frame 19-22 Screen Tests"]
        V3["XcodeBuild Simulator Verification"]
    end

    S0 --> S1
    S0 --> S2
    S1 --> S3
    S2 --> S3
```

| Verification Suite | Target Areas | Target Pass Rate |
| :--- | :--- | :---: |
| **Existing Unit Tests** | `ModelTests`, `NavigationTests`, `ThemeTests`, `StorageTests`, `SecurityTests` | **105 / 105 Passing** |
| **Assessment Screen Tests** | `ScreenViewTests` (Frames 01–10 updated styling & pinned buttons) | **10 / 10 Passing** |
| **New Screen Tests** | `NewScreenTests` (Frames 19–22 models, views, and routing) | **8 / 8 Passing** |
| **Compiler Warnings** | Xcode toolchain build with strict concurrency check | **0 Warnings** |
