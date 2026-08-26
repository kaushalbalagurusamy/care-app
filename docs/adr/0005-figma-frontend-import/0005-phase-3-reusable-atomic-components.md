# ADR 0005.3: Phase 3 — Reusable Atomic UI Components & Design System

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

Across the 10 Figma frames, recurring atomic and composite components form the core design system under `ios/CAREApp/Components/`. These components must be decoupled, individually previewable, and validated for touch target compliance, visual snapshot regression, and interactive states.

### Architectural Deliverables
1. **`HeaderNavBar`**: Top navigation component with back button, step progress indicator, and profile action.
2. **`DonutChartView` & `DonutSegmentShape`**: Dynamic radial gauge component consuming an array of `[DonutSegment(color: Color, percentage: Double)]` dynamically computed from Phase 2 models.
3. **`ScoreBubbleView`**: Circular score gauge visualizing 0-100 safety scores with color-coded gradients.
4. **`IndividualResultCard`**: Result card component designed for swipeable paged carousels displaying person avatars, score badges, and domain breakdowns.
5. **`PageIndicatorDots`**: Reusable horizontal bubble series displaying active card position (`currentIndex` / `totalCount`).
6. **`PrimaryButton` & `SecondaryButton`**: Standard interactive buttons with pressed states, loading spinners, and haptic feedback.
7. **`RelationshipSelectionPill`**: Multi-select chip with icon, text, and selection borders.
8. **`FrequencySliderRow`**: Continuous slider row with custom thumb, track gradient, and frequency label.
9. **`ActionCardView` & `StreakBadgeView`**: Dashboard metric and quick-start card widgets.
10. **`ExpandableAccordionCard`**: Collapsible card with animated disclosure chevron.

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppTests/ComponentTests/` prior to implementing `Components/`:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-CMP-01`** | Visual / Snapshot | `ScoreBubbleView` | Render score bubble at `score: 85` (Green) and `score: 35` (Red) | Capture snapshot in Light & Dark modes | Image diff tolerance `< 0.1%` against Figma golden snapshot. |
| **`TEST-CMP-02`** | Unit / A11y | `PrimaryButton` | Instantiate standard `PrimaryButton(title: "Continue")` | Measure rendered bounding frame | `#expect(frame.width >= 44 && frame.height >= 44)` (Apple HIG minimum touch target size). |
| **`TEST-CMP-03`** | Unit / Interaction | `RelationshipSelectionPill` | Pill initialized with `isSelected: false` | Trigger tap action closure | `#expect(isSelected == true)`; trigger second tap yields `isSelected == false`. |
| **`TEST-CMP-04`** | Unit / Bounds | `FrequencySliderRow` | Slider bound to `@State value: Double` | Update value to `-0.5` and `1.5` | Value is clamped to valid range `[0.0, 1.0]`. |
| **`TEST-CMP-05`** | Unit / Dynamic Arc | `DonutChartView` | Pass segments summing to 1.0 (21% Safe, 39% Med, 40% High) | Compute arc start and end angles | Sum of arc angular degrees equals $360^\circ \pm 0.01^\circ$. |

---

## 3. Executable Test Contract (Swift Testing & Snapshot Spec)

```swift
import Testing
import SwiftUI
import SnapshotTesting
@testable import CAREApp

@Suite("Phase 3: Reusable Atomic UI Components Test Suite")
struct AtomicComponentTests {
    
    @Test("TEST-CMP-01: ScoreBubbleView visual regression matches Figma reference")
    func testScoreBubbleSnapshots() {
        let view = ScoreBubbleView(score: 85, maxScore: 100)
            .frame(width: 200, height: 200)
        
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 200, height: 200)))
    }

    @Test("TEST-CMP-02: PrimaryButton conforms to HIG 44pt touch target invariant")
    func testButtonTouchTargetDimension() {
        let button = PrimaryButton(title: "Continue", action: {})
        let minHeight = button.intrinsicMinHeight
        #expect(minHeight >= 44.0, "Button height \(minHeight) is below Apple HIG 44pt touch requirement")
    }

    @Test("TEST-CMP-05: DonutChartView geometry closes exact 360 degree circumference")
    func testDonutChartAngularGeometry() {
        let segments = [
            DonutSegment(color: .green, percentage: 0.21),
            DonutSegment(color: .yellow, percentage: 0.39),
            DonutSegment(color: .red, percentage: 0.40)
        ]
        let chart = DonutChartView(segments: segments)
        #expect(chart.totalAngularSpanDegrees == 360.0)
    }
}
```

---

## 4. SDD Verification Loop Harness

To verify the Red -> Green cycle autonomously:
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/AtomicComponentTests
```
