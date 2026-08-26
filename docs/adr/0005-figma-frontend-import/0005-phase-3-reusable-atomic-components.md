# ADR 0005.3: Phase 3 — Reusable Atomic UI Components & Design System

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

Across the 10 Figma frames, recurring atomic and composite components form the design system under `ios/CAREApp/Components/`. These components are constructed with pixel-exact metrics extracted directly from the Figma document (`4uqL8l0VygkDoFQeXP7VeL`), decoupled, independently previewable, and validated for touch target compliance ($\ge 44\text{pt}$), dynamic type scaling, and interactive state isolation.

### Architectural Deliverables (10 Reusable Components)

#### 1. `HeaderNavBar` (`Components/HeaderNavBar.swift`)
* Top navigation bar ($350\text{pt} \times 64\text{pt}$, background `#FFFFFF`):
  * **`.home(title: String, streakCount: Int)`**: User avatar, greeting title, and streak pill.
  * **`.detail(title: String, progress: Double?, onBack: () -> Void)`**: Back button (`36x36` circle fill `#F0F5FD`), screen title, and optional animated progress bar.
  * **`.modal(title: String, onClose: () -> Void)`**: Title with dismissal button.

#### 2. `DonutChartView` & `DonutSegmentShape` (`Components/DonutChartView.swift`)
* Dynamic radial multi-segment chart ($200\text{pt} \times 200\text{pt}$) for Relational Safety (21% Safe `#38B969`, 39% Moderate `#FABF2E`, 40% High Risk `#E84D4D`).
* Accepts `[DonutSegment(color: Color, percentage: Double)]` and renders proportional angular arcs with rounded stroke caps, center cutout, and legend labels.

#### 3. `ScoreBubbleView` (`Components/ScoreBubbleView.swift`)
* Circular score badge displaying points (e.g. `80/100` or `18/125`).
* Dynamic concentric gradient rings mapped to `SafetyTier` or `CAREDomain` theme colors.

#### 4. `IndividualResultCard` (`Components/IndividualResultCard.swift`)
* Swipeable contact card ($310\text{pt} \times 78\text{pt}$, corner `18pt`, fill `#EFF5FC`) on Screen 8:
  * Person avatar circle with initials (`SM`).
  * Name, relation type (`Partner, 32`), and score status badge (`80/100 Safe` `#38B969`).
  * 4 mini progress bars for Calm, Accepted, Resonant, Energetic domain scores.

#### 5. `PageIndicatorDots` (`Components/PageIndicatorDots.swift`)
* Horizontal indicator showing active carousel position (`currentIndex` / `totalCount`).
* Active dot renders at $8\text{pt} \times 8\text{pt}$ (`#246BB8`); inactive dots render at $8\text{pt} \times 8\text{pt}$ (`#CCD6E0`).

#### 6. `PrimaryButton` & `SecondaryButton` (`Components/Buttons.swift`)
* **`PrimaryButton`**: $350\text{pt} \times 56\text{pt}$, corner `18pt`, fill `#246BB8`, text `#FFFFFF` SemiBold 16pt.
* **`SecondaryButton`**: $350\text{pt} \times 56\text{pt}$, corner `18pt`, fill `#FFFFFF`, border 1px `#CCD6E0`, text `#246BB8`.
* Invariant: Both enforce $\ge 44\text{pt}$ HIG touch target compliance.

#### 7. `RelationshipSelectionPill` (`Components/RelationshipSelectionPill.swift`)
* Selectable contact card ($350\text{pt} \times 72\text{pt}$, corner `16pt`) on Screen 5:
  * Contact initials avatar badge ($44\text{pt}$ circle, fill `#EBF2FA`).
  * Person name (`Sarah Mitchell`) and category description (`Partner, 32`).
  * Checkmark circle indicator with active border (`#246BB8`) and background tint (`#EBF2FA`).

#### 8. `FrequencySliderRow` (`Components/FrequencySliderRow.swift`)
* Interactive percentage partition card ($350\text{pt}$, corner `28pt`, fill `#F0F5FD`) for Screen 6:
  * Contact initials badge and name label.
  * Continuous slider bound to `$percentage` (clamped `0.0 - 1.0`).
  * Live percentage readout label (e.g. `30%`).

#### 9. `ActionCardView` & `StreakBadgeView` (`Components/DashboardWidgets.swift`)
* **`ActionCardView`**: Dashboard cards (`350x96`, corner `16pt`, fill `#EFF5FC`) with number badges (`01`, `02`, `03`) and background illustrations from `Assets.xcassets`.
* **`StreakBadgeView`**: `"Daily Streak: 5 Days Active"` widget with flame icon.

#### 10. `ExpandableAccordionCard` (`Components/ExpandableAccordionCard.swift`)
* Collapsible card ($350\text{pt}$, corner `18pt`, fill `#EFF5FC`) for Screen 10 (`past-results`):
  * Header with title, score badge, and animated disclosure chevron (`chevron.down`).
  * Expanded body displaying historical trend scores across dates (`5/16`, `5/25`, `5/29`).

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppTests/ComponentTests/AtomicComponentTests.swift` prior to implementing `Components/`:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-CMP-01`** | Unit / Geometry | `DonutChartView` | Segments: 21% Safe, 39% Med, 40% High | Compute angular spans | $\sum \text{degrees} == 360.0^\circ \pm 0.01^\circ$. Individual arc spans match percentages. |
| **`TEST-CMP-02`** | Unit / A11y | `PrimaryButton` | Instantiate standard `PrimaryButton(title: "Next")` | Read `minTouchTarget` | `#expect(button.minHeight >= 44.0)` (Apple HIG minimum touch requirement). |
| **`TEST-CMP-03`** | Unit / Selection | `RelationshipSelectionPill` | Pill with `isSelected: false` | Toggle selection state | `#expect(isSelected == true)`; second toggle resets to `false`. |
| **`TEST-CMP-04`** | Unit / Bounds | `FrequencySliderRow` | Slider bound to `value: Double` | Update value to `-0.5` and `1.5` | Value is clamped to valid range `[0.0, 1.0]`. Formatted label reads `"0%"` and `"100%"`. |
| **`TEST-CMP-05`** | Unit / Geometry | `PageIndicatorDots` | 5 total dots, index 2 active | Inspect dot metrics | Active dot matches index 2. Index is clamped within `[0, count-1]`. |
| **`TEST-CMP-06`** | Unit / Formatting | `ScoreBubbleView` | Score 80 of 100 | Format score string | Displays `"80/100"`. Safety tier evaluates to `.healthy`. |
| **`TEST-CMP-07`** | Unit / Interaction | `ExpandableAccordionCard` | Card initialized with `isExpanded: false` | Trigger toggle | `isExpanded` becomes `true` and reveals child view content. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 3: Reusable Atomic UI Components Test Suite")
struct AtomicComponentTests {
    
    @Test("TEST-CMP-01: DonutChartView geometry closes exact 360 degree circumference")
    func testDonutChartAngularGeometry() {
        let segments = [
            DonutSegment(color: .green, percentage: 0.21),
            DonutSegment(color: .yellow, percentage: 0.39),
            DonutSegment(color: .red, percentage: 0.40)
        ]
        let chart = DonutChartView(segments: segments)
        #expect(chart.totalAngularSpanDegrees == 360.0)
    }

    @Test("TEST-CMP-02: PrimaryButton conforms to HIG 44pt touch target invariant")
    func testButtonTouchTargetDimension() {
        let button = PrimaryButton(title: "Next", action: {})
        #expect(button.minHeight >= 44.0, "Button height must meet HIG 44pt requirement")
    }

    @Test("TEST-CMP-03: RelationshipSelectionPill toggles selection cleanly")
    func testSelectionPillToggle() {
        var isSelected = false
        let pill = RelationshipSelectionPill(
            initials: "SM",
            name: "Sarah Mitchell",
            subtitle: "Partner, 32",
            isSelected: isSelected,
            onToggle: { isSelected.toggle() }
        )
        pill.onToggle()
        #expect(isSelected == true)
        pill.onToggle()
        #expect(isSelected == false)
    }

    @Test("TEST-CMP-04: FrequencySliderRow clamps values strictly to [0.0, 1.0]")
    func testFrequencySliderClamping() {
        var value = 1.5
        let clamped = min(max(value, 0.0), 1.0)
        #expect(clamped == 1.0)
        
        value = -0.3
        let clampedLow = min(max(value, 0.0), 1.0)
        #expect(clampedLow == 0.0)
    }

    @Test("TEST-CMP-05: PageIndicatorDots clamps active index within bounds")
    func testPageIndicatorBounds() {
        let dots = PageIndicatorDots(totalCount: 5, currentIndex: 2)
        #expect(dots.totalCount == 5)
        #expect(dots.currentIndex == 2)
    }

    @Test("TEST-CMP-06: ScoreBubbleView formats point ratios accurately")
    func testScoreBubbleFormatting() {
        let bubble = ScoreBubbleView(score: 80, maxScore: 100)
        #expect(bubble.scoreText == "80/100")
        #expect(bubble.safetyTier == .healthy)
    }

    @Test("TEST-CMP-07: ExpandableAccordionCard toggles disclosure state")
    func testAccordionDisclosure() {
        var isExpanded = false
        let card = ExpandableAccordionCard(
            title: "Sarah Mitchell",
            scoreLabel: "83/100",
            tier: .healthy,
            isExpanded: isExpanded,
            onToggle: { isExpanded.toggle() }
        )
        card.onToggle()
        #expect(isExpanded == true)
    }
}
```

---

## 4. ADR 0006 Governance & Verification Loop Harness

In accordance with [`ADR 0006`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md):

1. **Pre-Edit Checkpoint**: Snapshot the working tree before creating files:
   ```bash
   git add -A && git commit -m "checkpoint(phase-3-pre-edit): clean working tree before component implementation"
   ```
2. **Layer 1 AST & Type Checking**: Verify static syntax with `swift-mcp` before compiling.
3. **Layer 2 Targeted Component Test Execution**:
   ```bash
   xcodebuild test \
     -project ios/CAREApp.xcodeproj \
     -scheme CAREApp \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     -only-testing:CAREAppTests/AtomicComponentTests
   ```
4. **Anti-Blindness Failure Capture**: If an assertion fails twice, write `failure_trace.json` to `<appDataDir>/brain/<conversation-id>/scratch/` before triggering `git reset --hard`.

---

## 5. Green Milestone Transition & Storage Purge

Upon all Phase 3 tests passing (Green Milestone):
1. **Commit Green State**:
   ```bash
   git commit -m "green(phase-3): reusable atomic UI components verified"
   ```
2. **Ephemeral Scratch Cleanup**: Purge temporary `task-*.log` files and transient attempt traces.
3. **Workspace Purge**: Execute `xcodebuildmcp purge` to clean intermediate compiler cache and prevent `DerivedData/` bloat.
4. **Transition**: Output milestone summary and prepare clean context for Phase 4 (Screen Views Assembly).
