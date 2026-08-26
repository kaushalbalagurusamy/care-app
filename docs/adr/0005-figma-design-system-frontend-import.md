# ADR 0005: Figma Design System to Native SwiftUI Import Architecture

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

## Context

The CARE App user interface has been fully designed in Figma ([`C.A.R.E. App`](https://www.figma.com/design/4uqL8l0VygkDoFQeXP7VeL/C.A.R.E.-App?node-id=0-1), File Key: `4uqL8l0VygkDoFQeXP7VeL`), comprising 10 core screens spanning onboarding, assessment configuration, interactive questionnaires, and safety results visualizations. 

To maintain high code quality, strict Swift 6 concurrency compliance, and 1:1 design fidelity without monolithic or messy view code, the frontend implementation must follow a staged, phased architecture paired with a strict **Spec-Driven Development (SDD)** and **Test-Driven Development (TDD)** verification loop.

## Decision

We establish a 5-phase modular import pipeline for converting the Figma design into a native SwiftUI application under `ios/CAREApp/`. Every phase includes an explicit **Test Specification Matrix** that must be implemented as failing tests prior to feature implementation.

Each phase is governed by its own detailed architectural decision specification located in [`docs/adr/0005-figma-frontend-import/`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/):

1. **[`Phase 1: Design Tokens & Assets`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-1-design-tokens-and-assets.md)**
   * *Implementation*: Color palettes, typography scales, spacing grids, corner radii, and asset catalog staging.
   * *Test Spec*: WCAG AA contrast ratio assertions, Dynamic Type scaling invariants, asset catalog presence tests.
2. **[`Phase 2: Domain Data Models & Navigation State`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-2-domain-models-and-navigation.md)**
   * *Implementation*: Definition of Swift 6 `@Observable` coordinators and immutable domain entities.
   * *Test Spec*: JSON schema serialization/decoding, safety score calculation formulas, router state machine navigation invariants.
3. **[`Phase 3: Reusable Atomic UI Components`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-3-reusable-atomic-components.md)**
   * *Implementation*: Shared design system primitives (header bars, score bubbles, sliders, pills, cards).
   * *Test Spec*: Visual snapshot regression (Light/Dark mode), 44pt+ touch target invariants, component stateful interaction tests.
4. **[`Phase 4: Screen Views Implementation`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-4-screen-views-implementation.md)**
   * *Implementation*: Concrete implementation of all 10 Figma frames with dedicated Xcode Canvas previews.
   * *Test Spec*: Screen hierarchy rendering assertions, view state injection, mock scenario coverage, layout boundary tests.
5. **[`Phase 5: Navigation Wiring, Build & Accessibility Audit`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0005-figma-frontend-import/0005-phase-5-navigation-wiring-and-audit.md)**
   * *Implementation*: Integration into `ContentView.swift`, `XcodeBuildMCP` validation, and VoiceOver/Dynamic Type compliance checks.
   * *Test Spec*: Full 10-screen XCUITest user journeys, 0-warning compilation enforcement, automated VoiceOver accessibility traversal.

---

## Global Verification Harness & Test Framework Matrix

| Testing Layer | Framework / Tool | Test Target | Verification Command |
| :--- | :--- | :--- | :--- |
| **Unit & Contract** | Swift Testing (`import Testing`) | `ios/CAREAppTests/Unit/` | `xcodebuild test -scheme CAREApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` |
| **Visual Regression** | `SnapshotTesting` (Point-Free) | `ios/CAREAppTests/Snapshots/` | `xcodebuild test -only-testing:CAREAppTests/SnapshotTests` |
| **Integration** | `URLProtocol` & `TestClient` | `ios/CAREAppTests/Integration/` | `xcodebuild test -only-testing:CAREAppTests/IntegrationTests` |
| **E2E & Accessibility** | `XCTest` / `XCUITest` | `ios/CAREAppUITests/` | `xcodebuild test -scheme CAREAppUITests -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` |

---

## Consequences

* **Pros**: Complete end-to-end test coverage before writing view code; zero regressions during refactoring; mathematically verified scoring calculations; guaranteed WCAG accessibility compliance.
* **Cons**: Requires creating test targets and mock data fixtures upfront.
