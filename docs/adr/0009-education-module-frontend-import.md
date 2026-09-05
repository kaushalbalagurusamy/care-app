# ADR 0009: Psychoeducation & Clinical Neuroscience Module Import Architecture

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Context & Motivation

Following the successful verification of the Core Assessment engine (ADRs 0001–0005), Local-First Persistence & Sync (ADR 0007), and Biometric Security (ADR 0008), CARE App is expanding into its second foundational pillar: **Clinical Psychoeducation & Relational Neuroscience**.

The new Figma page (`"Education"`, Page ID `120:3` in file `4uqL8l0VygkDoFQeXP7VeL`) establishes a comprehensive curriculum grounded in the neurobiological research of Dr. Amy Banks MD, Dr. Jean Baker Miller, and Relational-Cultural Theory (RCT).

To eliminate previous visual replication inaccuracies and guarantee 100% mathematical and layout fidelity:
1. **Direct Component & Token Extraction**: Layout bounds, Auto-Layout constraints, typography hierarchies, and color fills are imported directly via the Figma REST API.
2. **Direct Frame Render Exports**: High-resolution image renders of all 7 Figma frames are exported directly into `docs/figma_frames/` (`11_education_topics_frame_122_4.png` through `17_impact_of_relationships_frame_176_206.png`) for visual fidelity review.
3. **Structured Domain Data Manifest**: Educational lessons, founder biographies, the "5 Good Things", and neural pathway descriptions are encapsulated in type-safe, localized JSON domain models rather than hardcoded view strings.
4. **Spec-Driven & Test-Driven Development (SDD/TDD)**: Every component, data model, navigation route, and reading state transition is verified with unit, component, screen, and UI tests.

---

## 2. Figma Page Specification (`Page 2: Education` / Node `120:3`)

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             Figma Page 2 Direct Image Renders Inventory                          │
├─────────┬───────────────────────────────────────────┬──────────────┬─────────────────────────────┤
│ Node ID │ Frame Name                                │ Dimensions   │ Render File Path            │
├─────────┼───────────────────────────────────────────┼──────────────┼─────────────────────────────┤
│ 122:4   │ education-topics                          │ 390 × 844    │ 11_education_topics...png   │
│ 146:5   │ relational-neuroscience-detail            │ 390 × 1459   │ 12_relational_neuro...png   │
│ 156:4   │ relational-cultural-theory                │ 390 × 1950   │ 13_relational_cult...png    │
│ 176:2   │ neuroplasticity-detail                    │ 390 × 1004   │ 14_neuroplasticity...png    │
│ 176:70  │ brain-healthy-relationships-detail        │ 390 × 998    │ 15_brain_healthy...png      │
│ 176:138 │ power-over-vs-power-with-detail           │ 390 × 983    │ 16_power_over_vs...png      │
│ 176:206 │ impact-of-relationships-detail            │ 390 × 962    │ 17_impact_of_rel...png      │
└─────────┴───────────────────────────────────────────┴──────────────┴─────────────────────────────┘
```

---

## 3. Modular Sub-ADR Breakdown

Execution is partitioned into 5 self-contained, context-bounded sub-ADRs:

| Sub-ADR | Focus Scope | Key Deliverables & Test Suites | Status |
| :--- | :--- | :--- | :---: |
| [`0009.1: Data Models & Manifest`](docs/adr/0009-education-module-import/0009-phase-1-education-domain-models-and-data-manifest.md) | Models & Content Engine | `EducationTopic`, `FounderProfile`, `FiveGoodThingsItem`, `EducationManifest.json` (`EducationModelTests`) | Proposed |
| [`0009.2: Atomic Components`](docs/adr/0009-education-module-import/0009-phase-2-reusable-education-components.md) | Reusable UI Components | `EducationTopicCard`, `FounderCard`, `FiveGoodThingsCard`, `NeurobiologyPathwayCard`, `KeyTakeawaysCard` (`EducationComponentTests`) | Proposed |
| [`0009.3: Screen Views`](docs/adr/0009-education-module-import/0009-phase-3-education-screen-views.md) | 7 Figma Frames | `EducationTopicsView`, `TopicDetailView` with dynamic templates for all 6 lessons (`EducationScreenTests`) | Proposed |
| [`0009.4: Navigation & Progress`](docs/adr/0009-education-module-import/0009-phase-4-navigation-routing-and-progress-tracking.md) | Routing & Reading State | `AppRoute.education`, `AppRoute.educationDetail(topic)`, Home Dashboard Card, `EducationProgressRepositoryProtocol` (`EducationNavigationTests`, `EducationProgressTests`) | Proposed |
| [`0009.5: Verification & A11y`](docs/adr/0009-education-module-import/0009-phase-5-testing-accessibility-and-verification.md) | E2E Tests & Accessibility | Full VoiceOver audit, Dynamic Type scaling, `XCUITest` Education user journeys (`CAREAppUITests`) | Proposed |

---

## 4. Test Verification Matrix & Coverage Targets

```
┌────────────────────────────────┬───────────────────────────────┬───────────────┐
│ Suite Name                     │ Target Scope                  │ Test Count    │
├────────────────────────────────┼───────────────────────────────┼───────────────┤
│ 1. EducationModelTests         │ JSON Decoding & Validation    │ 4 tests       │
│ 2. EducationComponentTests     │ Atomic Card Rendering         │ 5 tests       │
│ 3. EducationScreenTests        │ Hub & Detail Screen Trees     │ 7 tests       │
│ 4. EducationNavigationTests    │ Route Transitions & Deep Link │ 3 tests       │
│ 5. EducationProgressTests      │ Reading State & Persistence   │ 2 tests       │
│ 6. EducationUITests            │ E2E Reader User Journey       │ 2 UI tests    │
├────────────────────────────────┴───────────────────────────────┼───────────────┤
│ Total Planned Phase 8 Assertions                               │ 23 Tests      │
│ Current Baseline Passing Tests                                 │ 66 Tests      │
│ Target Global Test Count                                       │ 89 Tests      │
└────────────────────────────────────────────────────────────────┴───────────────┘
```
