# ADR 0009.1: Phase 1 — Education Content Data Models & Bundled Manifest

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 1 establishes the type-safe Swift 6 domain models and bundled JSON content manifest representing the 6 psychoeducation topics extracted directly from Figma:
1. **Relational-Cultural Theory (RCT)** (Overview, Founders, "5 Good Things", Mutual Empathy)
2. **Relational Neuroscience** (4 C.A.R.E. neural pathways: Calm, Accepted, Resonant, Energetic)
3. **Neuroplasticity** (Synaptic rewiring through safe connections)
4. **The Brain in Healthy Relationships** (Biochemical responses, oxytocin, vagal tone)
5. **Power-Over vs. Power-With** (Relational power dynamics & mutual empowerment)
6. **The Impact of Relationships** (Physiological health, cardiovascular wellness, longevity)

### Architectural Deliverables
* **`EducationTopic` Model (`Models/Education/EducationTopic.swift`)**: Identifiable, Codable, Hashable enum & struct representing topics, icons, estimated read time, and summaries.
* **`FounderProfile` & `FiveGoodThingsItem` Models (`Models/Education/EducationSubmodels.swift`)**.
* **`EducationContentSection` Models**: Strongly-typed sections (`.overview`, `.founders([FounderProfile])`, `.fiveGoodThings([FiveGoodThingsItem])`, `.keyTakeaways([String])`, `.callout(title, body, icon)`).
* **Bundled `EducationManifest.json` (`Resources/Education/EducationManifest.json`)**: Pre-validated, localized content payload matching Figma node contents verbatim.

---

## 2. SOTA Test Specification Matrix (`EducationModelTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDM-01`** | Unit / Decode | Manifest Decoding | Bundled `EducationManifest.json` | Decode to `[EducationTopic]` | Successfully decodes all 6 topics with 0 nil fields. |
| **`TEST-EDM-02`** | Unit / Integrity | 6 Topics Presence | Decoded manifest | Inspect topic IDs and slugs | Exactly contains the 6 required curriculum topics. |
| **`TEST-EDM-03`** | Unit / Model | RCT Founders & 5 Good Things | Decode RCT topic | Inspect `founders` & `fiveGoodThings` | Exactly 4 founders and 5 items present with complete bios and descriptions. |
| **`TEST-EDM-04`** | Unit / Immutability | Sendable & Hashable | Topic instances | Verify `Sendable` and `Hashable` conformance | Safe for Swift 6 strict concurrency across threads. |

---

## 3. Acceptance Criteria
- [ ] Complete bundled `EducationManifest.json` matching Figma copy verbatim.
- [ ] Zero runtime force unwrap failures during JSON decoding.
- [ ] Passes all 4 model test assertions (`TEST-EDM-01` through `TEST-EDM-04`).
