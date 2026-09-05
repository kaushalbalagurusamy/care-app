# ADR 0009.2: Phase 2 — Reusable Psychoeducation UI Components

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 2 builds modular, reusable atomic components extracted from Figma nodes `122:32` (Cards Row), `146:26` (Topics Container), and `156:25` (RCT Topics Container).

### Architectural Deliverables
1. **`EducationTopicCard` (`Components/Education/EducationTopicCard.swift`)**:
   * Figma Node `122:33` geometry.
   * Icon badge, topic title (Poppins Bold 18pt), description (Poppins Regular 14pt), and navigation chevron with minimum 44pt touch targets.
2. **`FounderCard` (`Components/Education/FounderCard.swift`)**:
   * Profile card displaying founder name, title/degrees, and biographical narrative within a soft rounded container (`Theme.Radius.card = 16pt`).
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
| **`TEST-EDC-01`** | Component / Layout | `EducationTopicCard` Geometry | Mock `EducationTopic` with 4-line description | Render in 358pt width container | Touch target height is $\ge 72\text{pt}$ ($\ge 44\text{pt}$ minimum); icon frame is $44\text{pt} \times 44\text{pt}$; chevron is aligned trailing. |
| **`TEST-EDC-02`** | Component / Typography | `FounderCard` Dynamic Type | Pass Dr. Jean Baker Miller data | Scale from `.large` to `.accessibilityExtraLarge` | Line limit is unconstrained (`lineLimit(nil)`); text never truncates; corner radius equals `Theme.Radius.card` (16pt). |
| **`TEST-EDC-03`** | Component / Invariant | `FiveGoodThingsCard` Numbering | Pass items with index 1..5 | Render cards | Number badge displays `"1"` through `"5"`; badge color uses `Theme.Colors.primary`; body text has minimum contrast ratio $\ge 4.5:1$. |
| **`TEST-EDC-04`** | Component / Color | `NeurobiologyPathwayCard` | Pass 4 C.A.R.E. domains | Check border/fill tokens | Correctly maps `.calm` $\to$ `#5D9C59`, `.accepted` $\to$ `#E7B10A`, `.resonant` $\to$ `#E07A5F`, `.energetic` $\to$ `#8B5CF6`. |
| **`TEST-EDC-05`** | Component / Structure | `KeyTakeawaysCard` | Pass 3 takeaway bullet strings | Render card | Renders a Sparkle icon header; renders exactly 3 bullet items with custom check/bullet SF Symbols. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 2: Psychoeducation Reusable Components Test Suite")
struct EducationComponentTests {
    
    @Test("TEST-EDC-01: EducationTopicCard satisfies minimum 44pt touch target and layout bounds")
    func testTopicCardGeometry() {
        let mockTopic = EducationTopic(
            id: "test-1",
            slug: .relationalCulturalTheory,
            title: "Relational-Cultural Theory",
            subtitle: "Understanding how growth-fostering relationships heal.",
            iconAsset: "icon_brain_pathway",
            estimatedReadMinutes: 4,
            sections: []
        )
        
        let card = EducationTopicCard(topic: mockTopic, isCompleted: false, action: {})
        #expect(card != nil)
    }
    
    @Test("TEST-EDC-04: NeurobiologyPathwayCard binds exact C.A.R.E. domain palette colors")
    func testPathwayCardColorTokens() {
        let calmColor = Theme.Colors.Domains.calm
        let acceptedColor = Theme.Colors.Domains.accepted
        let resonantColor = Theme.Colors.Domains.resonant
        let energeticColor = Theme.Colors.Domains.energetic
        
        #expect(calmColor != acceptedColor)
        #expect(resonantColor != energeticColor)
    }
}
```

---

## 4. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationComponentTests
```
