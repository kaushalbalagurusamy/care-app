# ADR 0009.3: Phase 3 — Education Screen Views Implementation (7 Figma Frames)

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 3 implements the full screen views corresponding to all 7 Figma frames on Page 2 (`Education`):
1. **`EducationTopicsView.swift` (Frame `122:4`)**: Main psychoeducation hub with header nav, introductory hero banner, and the 6 topic cards in a fluid scroll view.
2. **`TopicDetailView.swift`**: Unified, scalable template view that dynamically renders any of the 6 detailed curriculum lessons based on `EducationTopic`:
   * **Frame `156:4`**: Relational-Cultural Theory Deep Dive (Overview, Founders grid, "5 Good Things" interactive list, Mutual Empathy).
   * **Frame `146:5`**: Relational Neuroscience Deep Dive (4 CARE pathways & brain mappings).
   * **Frame `176:2`**: Neuroplasticity Deep Dive.
   * **Frame `176:70`**: The Brain in Healthy Relationships Deep Dive.
   * **Frame `176:138`**: Power-Over vs. Power-With Deep Dive.
   * **Frame `176:206`**: The Impact of Relationships Deep Dive.

### Architectural Deliverables
* **`Views/Education/EducationTopicsView.swift`**
* **`Views/Education/TopicDetailView.swift`**
* Standardized `HeaderNavBar` integration across all education screens.

---

## 2. SOTA Test Specification Matrix (`EducationScreenTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDS-01`** | Screen / Hierarchy | `EducationTopicsView` (Hub Frame `122:4`) | AppRouter injected, 6 topics loaded | Inspect SwiftUI view hierarchy | Contains `HeaderNavBar`, Hero title "Education", and 6 `EducationTopicCard` views in a `LazyVStack` with 16pt spacing. |
| **`TEST-EDS-02`** | Screen / Hierarchy | RCT Detail (`156:4`, 1950pt Height) | Load `.relationalCulturalTheory` topic | Render `TopicDetailView` | Contains Overview card, 4 `FounderCard` items, 5 `FiveGoodThingsCard` items, and a "Complete Topic" primary button. |
| **`TEST-EDS-03`** | Screen / Hierarchy | Neuroscience Detail (`146:5`, 1459pt Height) | Load `.relationalNeuroscience` topic | Render `TopicDetailView` | Contains 4 `NeurobiologyPathwayCard` views representing C, A, R, and E pathways. |
| **`TEST-EDS-04`** | Screen / Template | Neuroplasticity (`176:2`) | Load `.neuroplasticity` topic | Render `TopicDetailView` | Renders synaptic rewiring narrative, exercise suggestions, and Key Takeaways. |
| **`TEST-EDS-05`** | Screen / Template | Brain in Healthy Relationships (`176:70`) | Load `.brainHealthyRelationships` topic | Render `TopicDetailView` | Renders oxytocin and autonomic nervous system regulation sections. |
| **`TEST-EDS-06`** | Screen / Template | Power-Over vs. Power-With (`176:138`) | Load `.powerOverVsPowerWith` topic | Render `TopicDetailView` | Renders comparison grid highlighting control vs. mutual empowerment. |
| **`TEST-EDS-07`** | Screen / Template | Impact of Relationships (`176:206`) | Load `.impactOfRelationships` topic | Render `TopicDetailView` | Renders cardiovascular health, immune function, and longevity evidence. |

---

## 3. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationScreenTests
```
