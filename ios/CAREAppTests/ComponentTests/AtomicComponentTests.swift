import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 3: Reusable Atomic UI Components Test Suite")
struct AtomicComponentTests {
    
    @Test("TEST-CMP-01: DonutChartView geometry closes exact 360 degree circumference")
    func testDonutChartAngularGeometry() {
        let segments = [
            DonutSegment(title: "Safe", color: .green, percentage: 0.21),
            DonutSegment(title: "Moderate", color: .yellow, percentage: 0.39),
            DonutSegment(title: "High Risk", color: .red, percentage: 0.40)
        ]
        let chart = DonutChartView(segments: segments)
        #expect(abs(chart.totalAngularSpanDegrees - 360.0) < 0.001)
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

    @Test("TEST-CMP-04: FrequencySliderRow percentage formats properly")
    func testFrequencySliderFormatting() {
        var pct = 0.30
        let binding = Binding(get: { pct }, set: { pct = $0 })
        let slider = FrequencySliderRow(initials: "SM", name: "Sarah Mitchell", percentage: binding)
        #expect(slider.percentageString == "30%")
    }

    @Test("TEST-CMP-05: PageIndicatorDots clamps active index within bounds")
    func testPageIndicatorBounds() {
        let dots = PageIndicatorDots(totalCount: 5, currentIndex: 2)
        #expect(dots.totalCount == 5)
        #expect(dots.currentIndex == 2)
        
        let dotsOverflow = PageIndicatorDots(totalCount: 5, currentIndex: 10)
        #expect(dotsOverflow.currentIndex == 4)
    }

    @Test("TEST-CMP-06: ScoreBubbleView formats point ratios accurately")
    func testScoreBubbleFormatting() {
        let bubble = ScoreBubbleView(score: 80, maxScore: 100)
        #expect(bubble.scoreText == "80/100")
        #expect(bubble.safetyTier == .healthy)
        
        let bubbleMod = ScoreBubbleView(score: 65, maxScore: 100)
        #expect(bubbleMod.safetyTier == .moderate)
        
        let bubbleHigh = ScoreBubbleView(score: 45, maxScore: 100)
        #expect(bubbleHigh.safetyTier == .highRisk)
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
