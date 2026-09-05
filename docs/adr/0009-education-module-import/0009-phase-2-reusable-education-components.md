# ADR 0009.2: Phase 2 — Reusable Psychoeducation UI Components

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 2 builds the modular, reusable atomic components extracted from Figma nodes `122:32` (Cards Row), `146:26` (Topics Container), and `156:25` (RCT Topics Container).

### Architectural Deliverables
1. **`EducationTopicCard` (`Components/Education/EducationTopicCard.swift`)**:
   * Figma Node `122:33` geometry.
   * Icon badge, topic title (Poppins Bold 18pt), description (Poppins Regular 14pt), and navigation chevron with minimum 44pt touch targets.
2. **`FounderCard` (`Components/Education/FounderCard.swift`)**:
   * Profile card displaying founder name, title/degrees, and biographical narrative within a soft rounded container (`Theme.Radius.card`).
3. **`FiveGoodThingsCard` (`Components/Education/FiveGoodThingsCard.swift`)**:
   * Numbered pill badge (1–5), aspect title (Zest, Sense of Worth, Clarity, Creativity, Connection), and neurobiological explanation.
4. **`NeurobiologyPathwayCard` (`Components/Education/NeurobiologyPathwayCard.swift`)**:
   * Color-coded C.A.R.E. domain banner (Calm, Accepted, Resonant, Energetic) with anatomical brain region callout (Smart Vagus, DACC, Mirror Neurons, Dopamine).
5. **`KeyTakeawaysCard` (`Components/Education/KeyTakeawaysCard.swift`)**:
   * Bulleted action insights container with sparkle icon badge.

---

## 2. SOTA Test Specification Matrix (`EducationComponentTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDC-01`** | Component | `EducationTopicCard` Layout | Pass mock topic data | Render in container | Title and description are rendered; card height satisfies $\ge 44\text{pt}$ minimum. |
| **`TEST-EDC-02`** | Component | `FounderCard` Bio Hierarchy | Pass Dr. Jean Baker Miller data | Render card | Name, subtitle, and biography text nodes exist in hierarchy. |
| **`TEST-EDC-03`** | Component | `FiveGoodThingsCard` Geometry | Pass "Zest" item | Render card | Badge number "1" and descriptive copy are present with proper padding. |
| **`TEST-EDC-04`** | Component | `NeurobiologyPathwayCard` Color Tokens | Pass `.calm` domain | Render card | Matches `Theme.Colors.Domains.calm` accent border/fill. |
| **`TEST-EDC-05`** | Component | `KeyTakeawaysCard` Bullet Rendering | Pass 3 takeaway strings | Render card | Exactly 3 bulleted text elements rendered. |

---

## 3. Acceptance Criteria
- [ ] 100% token adherence (`Theme.Colors`, `Theme.Typography`, `Theme.Spacing`).
- [ ] Passes all 5 component test assertions (`TEST-EDC-01` through `TEST-EDC-05`).
