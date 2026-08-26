import SwiftUI

// MARK: - High-Fidelity Design System Showcase & Storybook (Figma Matched)
public struct ComponentShowcaseView: View {
    @State private var sampleAllocations = [
        ParticipantAllocation(initials: "SM", firstName: "Sarah", percentage: 0.30),
        ParticipantAllocation(initials: "JC", firstName: "James", percentage: 0.25),
        ParticipantAllocation(initials: "LC", firstName: "Linda", percentage: 0.20),
        ParticipantAllocation(initials: "DO", firstName: "David", percentage: 0.15),
        ParticipantAllocation(initials: "RS", firstName: "Rachel", percentage: 0.10)
    ]
    
    @State private var isPillSelected1: Bool = true
    @State private var isPillSelected2: Bool = false
    @State private var isAccordionExpanded: Bool = true
    @State private var activeCardIndex: Int = 0
    @State private var buttonLoading: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: 1. Header Navigation Bar
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Header Navigation Bar (4 Circular Icons)")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HeaderNavBar(
                            showBackButton: true,
                            showHomeButton: true,
                            showChartButton: true,
                            showProfileButton: true,
                            title: "C.A.R.E. App"
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    }
                    
                    // MARK: 2. Vertical Time Allocation Partition Bubble (Screen 6)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("2. Screen 6: Vertical Time Allocation Bubble (5% Snap)")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Drag the custom handles between borders to adjust % in 5% steps")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        VerticalTimeAllocationBubble(allocations: $sampleAllocations)
                    }
                    
                    // MARK: 3. Donut Charts (Score Composition & Relational Safety)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3. Donut Charts (Rounded Caps & Angular Gaps)")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        // Score Composition Bubble
                        BubbleCardContainer(title: "Score Composition") {
                            VStack(spacing: 16) {
                                DonutChartView(
                                    segments: [
                                        DonutSegment(title: "Calm", color: Theme.Colors.Domains.calm, percentage: 0.25),
                                        DonutSegment(title: "Accepted", color: Theme.Colors.Domains.accepted, percentage: 0.25),
                                        DonutSegment(title: "Resonant", color: Theme.Colors.Domains.resonant, percentage: 0.25),
                                        DonutSegment(title: "Energetic", color: Theme.Colors.Domains.energetic, percentage: 0.25)
                                    ],
                                    gapDegrees: 8.0
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Relational Safety Bubble
                        BubbleCardContainer(title: "Relational Safety", showInfoIcon: true) {
                            VStack(spacing: 20) {
                                DonutChartView(
                                    segments: [
                                        DonutSegment(title: "Safe", color: Theme.Colors.Safety.lowRisk, percentage: 0.21),
                                        DonutSegment(title: "Medium Risk", color: Theme.Colors.Safety.moderateRisk, percentage: 0.39),
                                        DonutSegment(title: "High Risk", color: Theme.Colors.Safety.highRisk, percentage: 0.40)
                                    ],
                                    gapDegrees: 8.0
                                )
                                .frame(maxWidth: .infinity)
                                
                                // Legend Rows
                                VStack(spacing: 8) {
                                    HStack {
                                        Circle().fill(Theme.Colors.Safety.lowRisk).frame(width: 10, height: 10)
                                        Text("Safe").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                        Spacer()
                                        Text("21%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    HStack {
                                        Circle().fill(Theme.Colors.Safety.moderateRisk).frame(width: 10, height: 10)
                                        Text("Medium Risk").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                        Spacer()
                                        Text("39%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    HStack {
                                        Circle().fill(Theme.Colors.Safety.highRisk).frame(width: 10, height: 10)
                                        Text("High Risk").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                        Spacer()
                                        Text("40%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // MARK: 4. Category Breakdown Accordion
                    BubbleCardContainer(title: "Category Breakdown") {
                        CategoryBreakdownAccordion(items: [
                            DomainBreakdownItem(
                                domain: .calm,
                                score: 18,
                                maxScore: 125,
                                subtitleTitle: "C is for Calm",
                                explanation: "Calmness is related to the functioning of the smart vagus nerve and your social engagement system. When these systems are healthy, they help you to modulate stress levels.",
                                vagalToneTitle: "Good Vagal Tone",
                                vagalToneExplanation: "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life."
                            ),
                            DomainBreakdownItem(
                                domain: .accepted,
                                score: 20,
                                maxScore: 125,
                                subtitleTitle: "A is for Accepted",
                                explanation: "Acceptance reflects feelings of belonging, safety, and mutual respect in your relational network.",
                                vagalToneTitle: "Belonging Signaling",
                                vagalToneExplanation: "Neural safety pathways activate when you feel recognized and accepted by your peers."
                            ),
                            DomainBreakdownItem(
                                domain: .resonant,
                                score: 15,
                                maxScore: 125,
                                subtitleTitle: "R is for Resonant",
                                explanation: "Resonance captures emotional attunement and mutual empathy.",
                                vagalToneTitle: "Co-Regulation Capacity",
                                vagalToneExplanation: "Co-regulation allows physiological calming through shared social connection."
                            ),
                            DomainBreakdownItem(
                                domain: .energetic,
                                score: 22,
                                maxScore: 125,
                                subtitleTitle: "E is for Energetic",
                                explanation: "Energy describes the vitality, motivation, and positive arousal derived from social bonds.",
                                vagalToneTitle: "Autonomic Vitality",
                                vagalToneExplanation: "Healthy relationships stimulate autonomic resilience and energized focus."
                            )
                        ])
                    }
                    
                    // MARK: 5. Results by Individual Bubble
                    BubbleCardContainer(title: "Results by Individual", showInfoIcon: true) {
                        let sampleResult = IndividualResult(
                            participant: AssessmentParticipant(
                                person: Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32),
                                percentTimeSpent: 0.30
                            ),
                            normalizedScore: 80.0,
                            safetyTier: .healthy,
                            domainBreakdown: [.calm: 18, .accepted: 20, .resonant: 15, .energetic: 22]
                        )
                        
                        VStack(spacing: 16) {
                            IndividualResultCard(result: sampleResult)
                                .frame(maxWidth: .infinity)
                            
                            PageIndicatorDots(totalCount: 5, currentIndex: activeCardIndex)
                            
                            HStack {
                                Button("Prev Dot") {
                                    if activeCardIndex > 0 { activeCardIndex -= 1 }
                                }
                                .font(Theme.Typography.caption)
                                
                                Spacer()
                                
                                Button("Next Dot") {
                                    if activeCardIndex < 4 { activeCardIndex += 1 }
                                }
                                .font(Theme.Typography.caption)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: 6. Buttons & Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("6. Action Buttons")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        PrimaryButton(title: "Begin the Survey", icon: "arrow.right", action: {})
                        PrimaryButton(title: "Next", action: {})
                        PrimaryButton(title: "View Past Results", icon: "chart.bar.fill", action: {})
                        SecondaryButton(title: "Return to Home", icon: "house.fill", action: {})
                    }
                    
                    // MARK: 7. Dashboard Widgets
                    VStack(alignment: .leading, spacing: 16) {
                        Text("7. Dashboard Modules")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        StreakBadgeView(daysCount: 5)
                        ActionCardView(imageName: "card_education_full", title: "Education", subtitle: "Learn Wellness", action: {})
                        ActionCardView(imageName: "card_assessment_full", title: "Assessment", subtitle: "Track Mind", action: {})
                        ActionCardView(imageName: "card_exercises_full", title: "Exercises", subtitle: "Active Care", action: {})
                    }
                    
                    // MARK: 8. Historical Accordion Cards
                    BubbleCardContainer(title: "Past Results Trend") {
                        ExpandableAccordionCard(
                            title: "Sarah Mitchell",
                            scoreLabel: "83/100 Safe",
                            tier: .healthy,
                            isExpanded: isAccordionExpanded,
                            onToggle: { isAccordionExpanded.toggle() }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Theme.Colors.background)
            .navigationTitle("C.A.R.E. Design System")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Previews
#Preview("High Fidelity Design System") {
    ComponentShowcaseView()
}
