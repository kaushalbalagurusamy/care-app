# ADR 0009.3: Phase 3 — Education Screen Views Implementation (8 Figma Frames)

* **Status**: Accepted
* **Date**: 2026-09-05 (Updated & Accepted 2026-09-08)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 3 implements the full screen views corresponding to all 8 Figma frames on Page 2 (`Education`):
1. **`EducationTopicsView.swift` (Frame `122:4`)**: Main psychoeducation hub with header nav, introductory hero banner, and the 6 topic cards in a fluid scroll view.
2. **`TopicDetailView.swift`**: Unified, scalable template view that dynamically renders any of the 6 detailed curriculum lessons based on `EducationTopic`:
   * **Frame `156:4`**: Relational-Cultural Theory Deep Dive (Overview, Founders grid, "5 Good Things" interactive list, Mutual Empathy, "Test Your Understanding" CTA).
   * **Frame `146:5`**: Relational Neuroscience Deep Dive (4 CARE pathways & brain mappings, "Test Your Understanding" CTA).
   * **Frame `176:2`**: Neuroplasticity Deep Dive (2 body paragraphs, illustrations, "Test Your Understanding" CTA).
   * **Frame `176:70`**: The Brain in Healthy Relationships Deep Dive (Biochemistry, vagal tone, illustrations, "Test Your Understanding" CTA).
   * **Frame `176:138`**: Power-Over vs. Power-With Deep Dive (Mutual empowerment narrative, illustrations, "Test Your Understanding" CTA).
   * **Frame `176:206`**: The Impact of Relationships Deep Dive (Cardiovascular & longevity resilience, illustrations, "Test Your Understanding" CTA).
3. **`EducationQuizView.swift` (Frame `201:4`)**: Interactive knowledge check screen featuring question prompt, 4 selectable `QuizOptionCard` pills, interactive feedback state (`rationale-container`), and "Return to {Page Name}" button.

### Architectural Deliverables
* **`Views/Education/EducationTopicsView.swift`**
* **`Views/Education/TopicDetailView.swift`**
* **`Views/Education/EducationQuizView.swift`**
* Standardized `HeaderNavBar` integration across all education screens.

---

## 2. SOTA Test Specification Matrix (`EducationScreenTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDS-01`** | Screen / Hierarchy | `EducationTopicsView` (Hub Frame `122:4`) | AppRouter injected, 6 topics loaded | Inspect SwiftUI view hierarchy | Contains `HeaderNavBar`, Hero title "Education", and 6 `EducationTopicCard` views in a `LazyVStack` with 16pt spacing. |
| **`TEST-EDS-02`** | Screen / Hierarchy | RCT Detail (`156:4`, 2418pt Height) | Load `.relationalCulturalTheory` topic | Render `TopicDetailView` | Contains Overview card, 4 `FounderCard` items, 5 `FiveGoodThingsCard` items, and "Test Your Understanding" primary button. |
| **`TEST-EDS-03`** | Screen / Hierarchy | Neuroscience Detail (`146:5`, 1459pt Height) | Load `.relationalNeuroscience` topic | Render `TopicDetailView` | Contains 4 `NeurobiologyPathwayCard` views representing C, A, R, and E pathways, and "Test Your Understanding" button. |
| **`TEST-EDS-04`** | Screen / Template | Neuroplasticity (`176:2`, 1460pt Height) | Load `.neuroplasticity` topic | Render `TopicDetailView` | Renders synaptic rewiring narrative, illustrations, and "Test Your Understanding" button. |
| **`TEST-EDS-05`** | Screen / Template | Brain in Healthy Relationships (`176:70`, 1565pt Height) | Load `.brainHealthyRelationships` topic | Render `TopicDetailView` | Renders oxytocin and vagal tone sections, illustrations, and "Test Your Understanding" button. |
| **`TEST-EDS-06`** | Screen / Template | Power-Over vs. Power-With (`176:138`, 1439pt Height) | Load `.powerOverVsPowerWith` topic | Render `TopicDetailView` | Renders mutual empowerment narrative, illustrations, and "Test Your Understanding" button. |
| **`TEST-EDS-07`** | Screen / Template | Impact of Relationships (`176:206`, 1418pt Height) | Load `.impactOfRelationships` topic | Render `TopicDetailView` | Renders cardiovascular health & longevity evidence, illustrations, and "Test Your Understanding" button. |
| **`TEST-EDS-08`** | Screen / Hierarchy | Knowledge Check Quiz (`201:4`, 844pt Height) | Load quiz for topic | Render `EducationQuizView` | Header shows "[Topic] Quiz", question container displays prompt, 4 `QuizOptionCard` pills rendered, selecting an answer reveals rationale and return button. |


---

## 3. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationScreenTests
```

---

## 4. Verification Results (2026-09-08)
* **Suite**: `EducationScreenTests` (8/8 Passed)
  * `TEST-EDS-01`: EducationTopicsView renders all 6 curriculum topics and handles selection — **PASSED**
  * `TEST-EDS-02`: TopicDetailView correctly renders Relational-Cultural Theory structure — **PASSED**
  * `TEST-EDS-03`: TopicDetailView correctly renders Relational Neuroscience 4 C.A.R.E. pathways — **PASSED**
  * `TEST-EDS-04`: TopicDetailView correctly renders Neuroplasticity illustrations and narrative — **PASSED**
  * `TEST-EDS-05`: TopicDetailView correctly renders The Brain in Healthy Relationships narrative — **PASSED**
  * `TEST-EDS-06`: TopicDetailView correctly renders Power-Over vs. Power-With narrative — **PASSED**
  * `TEST-EDS-07`: TopicDetailView correctly renders The Impact of Relationships narrative — **PASSED**
  * `TEST-EDS-08`: EducationQuizView evaluates answers and presents rationale — **PASSED**
* **Project Total**: **85 / 85 tests passing** (82 unit/integration + 3 UI). Zero regressions.
* **Top Bar Compliance**: Strict reuse of standardized `HeaderNavBar` across all screen views with optical alignment, touch target compliance ($\ge 44\text{pt}$), and router integration.
