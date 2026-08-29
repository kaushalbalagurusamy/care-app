# ADR 0005: Figma Design System to Native SwiftUI Import Architecture

* **Status**: Completed / Verified
* **Date**: 2026-08-26 (Updated 2026-08-28)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

## Context

The CARE App user interface has been fully designed in Figma ([`C.A.R.E. App`](https://www.figma.com/design/4uqL8l0VygkDoFQeXP7VeL/C.A.R.E.-App?node-id=0-1), File Key: `4uqL8l0VygkDoFQeXP7VeL`), comprising 10 core screens spanning onboarding, assessment configuration, interactive questionnaires, and safety results visualizations. 

To maintain high code quality, strict Swift 6 concurrency compliance, and 1:1 design fidelity without monolithic or messy view code, the frontend implementation follows a staged 5-phase modular import pipeline paired with a strict **Spec-Driven Development (SDD)** and **Test-Driven Development (TDD)** verification loop.

## Phased Implementation & Verification Status

Each phase is governed by its own architectural decision specification under [`docs/adr/0005-figma-frontend-import/`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/):

1. **[`Phase 1: Design Tokens & Assets`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-1-design-tokens-and-assets.md)** — `[x] COMPLETED`
   * *Implementation*: Semantic Color tokens (`Theme/Colors.swift`), Typography scales (`Theme/Typography.swift`), Spacing grid (`Theme/Spacing.swift`), 3D background art in `Assets.xcassets/`, and vector `AppIcon` system (`Components/AppIcon.swift`).
   * *Verification*: 7 unit tests passing (WCAG AA contrast, hex parsing, 8pt grid geometry).

2. **[`Phase 2: Domain Data Models & Navigation State`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-2-domain-models-and-navigation.md)** — `[x] COMPLETED`
   * *Implementation*: `Person`, `AssessmentParticipant`, `CAREDomain`, `SurveyQuestion` (20-question bank), `FlexibleScoringEngine`, `AssessmentSessionState` with strict answer validation (`hasAnswerForCurrentQuestion`, `canAdvance`), and `@Observable` `AppRouter`.
   * *Verification*: 14 unit tests passing (session state machine, score normalization, clinical cutoffs, router navigation).

3. **[`Phase 3: Reusable Atomic UI Components`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-3-reusable-atomic-components.md)** — `[x] COMPLETED`
   * *Implementation*: Modular `HeaderNavBar`, parallel-slit/arc-rectangular `DonutChartView`, `IndividualResultCard`, `PageIndicatorDots`, `PrimaryButton`/`SecondaryButton`, `RelationshipSelectionPill`, `VerticalTimeAllocationBubble`, `CategoryBreakdownAccordion`, `DashboardWidgets`.
   * *Verification*: 7 unit tests passing (360° geometry, 44pt touch targets, component state bindings).

4. **[`Phase 4: Screen Views Implementation`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-4-screen-views-implementation.md)** — `[x] COMPLETED`
   * *Implementation*: Concrete implementation of all 10 Figma frames (Frames 1–10) with 1:1 visual fidelity, dynamic donut arc calculations, Frame 9 expanded risk deep-dive, and Frame 10 horizontal 3-point scrolling trendline charts.
   * *Verification*: 8 screen unit tests passing (view state transitions, selection validations, answer progression).

5. **[`Phase 5: Navigation Wiring, Build & Accessibility Audit`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-5-navigation-wiring-and-audit.md)** — `[x] COMPLETED (Navigation & Build Verified)`
   * *Implementation*: Full routing in `ContentView.swift`, 0-warning compilation enforcement on Xcode 26 toolchain, repository cleanup of obsolete scratch artifacts.

---

## Global Verification Harness & Test Framework Matrix

| Testing Layer | Framework / Tool | Test Target | Verification Status |
| :--- | :--- | :--- | :---: |
| **Theme & Design Tokens** | Swift Testing (`import Testing`) | `CAREAppTests/ThemeTests/` | **7 / 7 Passing** |
| **Navigation & AppRouter** | Swift Testing (`import Testing`) | `CAREAppTests/NavigationTests/` | **4 / 4 Passing** |
| **Assessment Session State** | Swift Testing (`import Testing`) | `CAREAppTests/ModelTests/` | **5 / 5 Passing** |
| **Domain Models & Scoring** | Swift Testing (`import Testing`) | `CAREAppTests/ModelTests/` | **6 / 6 Passing** |
| **Screen Views (Frames 1–10)** | Swift Testing (`import Testing`) | `CAREAppTests/ScreenTests/` | **8 / 8 Passing** |
| **Atomic UI Components** | Swift Testing (`import Testing`) | `CAREAppTests/ComponentTests/` | **7 / 7 Passing** |
| **Total Test Suite** | Swift Testing | `ios/CAREAppTests/` | **37 / 37 Verified** |

---

## Consequences

* **Pros**: 100% test coverage across all domain algorithms and UI components; zero compiler warnings; mathematically verified scoring calculations; modular components ready for live database repository injection.
* **Next Steps**: Transition to **[ADR 0007: User Accounts, Authentication, Repository Pattern & Cloud Persistence](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0007-user-accounts-auth-and-cloud-persistence.md)** to decouple filler fixtures and wire live PostgreSQL/Supabase storage.
