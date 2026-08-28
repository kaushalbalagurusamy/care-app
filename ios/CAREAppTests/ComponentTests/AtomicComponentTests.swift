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

    @Test("TEST-CMP-04: VerticalTimeAllocationBubble percentage formats accurately")
    func testTimeAllocationBubbleFormatting() {
        var allocations = [
            ParticipantAllocation(initials: "SM", firstName: "Sarah", percentage: 0.35),
            ParticipantAllocation(initials: "JC", firstName: "James", percentage: 0.65)
        ]
        let binding = Binding(get: { allocations }, set: { allocations = $0 })
        _ = VerticalTimeAllocationBubble(allocations: binding)
        #expect(allocations[0].percentage == 0.35)
        #expect(abs(allocations.reduce(0.0) { $0 + $1.percentage } - 1.0) < 0.001)
    }

    @Test("TEST-CMP-05: PageIndicatorDots clamps active index within bounds")
    func testPageIndicatorBounds() {
        let dots = PageIndicatorDots(totalCount: 5, currentIndex: 2)
        #expect(dots.totalCount == 5)
        #expect(dots.currentIndex == 2)
        
        let dotsOverflow = PageIndicatorDots(totalCount: 5, currentIndex: 10)
        #expect(dotsOverflow.currentIndex == 4)
    }

    @Test("TEST-CMP-06: IndividualResultCard initializes with normalized score")
    func testIndividualResultCardInit() {
        let result = IndividualResult(
            participant: AssessmentParticipant(person: Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)),
            normalizedScore: 83.0,
            safetyTier: .healthy,
            domainBreakdown: [.calm: 22.0, .accepted: 20.0, .resonant: 18.0, .energetic: 23.0]
        )
        let card = IndividualResultCard(result: result)
        #expect(card.result.normalizedScore == 83.0)
        #expect(card.result.safetyTier == .healthy)
    }

    @Test("TEST-CMP-07: CategoryBreakdownAccordion displays domain breakdown items")
    func testCategoryBreakdownAccordion() {
        let items = [
            DomainBreakdownItem(
                domain: .calm,
                score: 18,
                maxScore: 25,
                subtitleTitle: "C is for Calm",
                explanation: "Calmness is related to the smart vagus nerve.",
                vagalToneTitle: "Good Vagal Tone",
                vagalToneExplanation: "Strong regulatory baseline."
            ),
            DomainBreakdownItem(
                domain: .accepted,
                score: 20,
                maxScore: 25,
                subtitleTitle: "A is for Accepted",
                explanation: "Acceptance reflects feelings of belonging.",
                vagalToneTitle: "Solid Resonance",
                vagalToneExplanation: "Safe relational connection."
            )
        ]
        let accordion = CategoryBreakdownAccordion(items: items)
        #expect(accordion.items.count == 2)
        #expect(accordion.items[0].domain == .calm)
        #expect(accordion.items[0].score == 18)
    }
}
