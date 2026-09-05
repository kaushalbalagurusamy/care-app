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
| **`TEST-EDS-01`** | Screen | `EducationTopicsView` Render | Render Hub screen | Inspect view tree | Header nav, hero title, and all 6 topic cards exist. |
| **`TEST-EDS-02`** | Screen | RCT Detail View Tree | Render RCT topic | Inspect view tree | Renders Overview, 4 Founders, 5 Good Things, and Footer button. |
| **`TEST-EDS-03`** | Screen | Relational Neuroscience Detail | Render Neuroscience topic | Inspect view tree | 4 C.A.R.E. neural pathways and anatomical mappings render. |
| **`TEST-EDS-04`** | Screen | Neuroplasticity Detail | Render Neuroplasticity topic | Inspect view tree | Synaptic wiring lessons and callout cards render. |
| **`TEST-EDS-05`** | Screen | Brain in Healthy Relationships Detail | Render Brain in Healthy Relationships | Inspect view tree | Biochemical response sections render accurately. |
| **`TEST-EDS-06`** | Screen | Power-Over vs Power-With Detail | Render Power dynamics topic | Inspect view tree | Empowerment comparison cards render accurately. |
| **`TEST-EDS-07`** | Screen | Impact of Relationships Detail | Render Impact topic | Inspect view tree | Physiological health & wellness sections render accurately. |

---

## 3. Acceptance Criteria
- [ ] 1:1 geometry, typography, and color match for all 7 Figma frames.
- [ ] Fluid vertical scrolling on iPhone 16 Pro and iPad form factors.
- [ ] Passes all 7 screen test assertions (`TEST-EDS-01` through `TEST-EDS-07`).
